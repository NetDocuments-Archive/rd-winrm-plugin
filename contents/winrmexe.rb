#!/usr/bin/ruby
gem 'winrm', '= 1.8.1'
require 'winrm'
auth = ENV['RD_CONFIG_AUTHTYPE']
user = ENV['RD_CONFIG_USER'].dup # for some reason these strings is frozen, so we duplicate it
pass = ENV['RD_CONFIG_PASS'].dup
host = ENV['RD_NODE_HOSTNAME']
port = ENV['RD_CONFIG_WINRMPORT']
shell = ENV['RD_CONFIG_SHELL']
realm = ENV['RD_CONFIG_KRB5_REALM']
command = ENV['RD_EXEC_COMMAND']
override = ENV['RD_CONFIG_ALLOWOVERRIDE']
host = ENV['RD_OPTION_WINRMHOST'] if ENV['RD_OPTION_WINRMHOST'] && (override == 'host' || override == 'all')
user = ENV['RD_OPTION_WINRMUSER'].dup if ENV['RD_OPTION_WINRMUSER'] && (override == 'user' || override == 'all')
pass = ENV['RD_OPTION_WINRMPASS'].dup if ENV['RD_OPTION_WINRMPASS'] && (override == 'user' || override == 'all')

if auth == 'ssl'
  endpoint = "https://#{host}:#{port}/wsman"
else
  endpoint = "http://#{host}:#{port}/wsman"
end
ooutput = ''
eoutput = ''

# Wrapper to fix: "not setting executing flags by rundeck for 2nd file in plugin"
# # https://github.com/rundeck/rundeck/issues/1421
# remove it after issue will be fixed
if File.exist?("#{ENV['RD_PLUGIN_BASE']}/winrmcp.rb") && !File.executable?("#{ENV['RD_PLUGIN_BASE']}/winrmcp.rb")
  File.chmod(0764, "#{ENV['RD_PLUGIN_BASE']}/winrmcp.rb")
end

# Wrapper ro avoid strange and undocumented behavior of rundeck
# Should be deleted after rundeck fix
# https://github.com/rundeck/rundeck/issues/602
command = command.gsub(/'"'"'' /, '\'')
command = command.gsub(/ ''"'"'/, '\'')
command = command.gsub(/ '"/, '"')
command = command.gsub(/"' /, '"')

# Wrapper for avoid unix style file copying then scripts run
# - not accept chmod call
# - replace rm -f into rm -force
# - auto copying renames file from .sh into .ps1, .bat or .wql in tmp directory
exit 0 if command.include? 'chmod +x /tmp/'

if command.include? 'rm -f /tmp/'
  shell = 'powershell'
  command = command.gsub(%r{rm -f /tmp/}, 'rm -force /tmp/')
end

if %r{/tmp/.*\.sh}.match(command)
  case shell
  when 'powershell'
    command = command.gsub(/\.sh/, '.ps1')
  when 'cmd'
    command = command.gsub(/\.sh/, '.bat')
  when 'wql'
    command = command.gsub(/\.sh/, '.wql')
  end
end

if ENV['RD_JOB_LOGLEVEL'] == 'DEBUG'
  puts 'variables:'
  puts "realm => #{realm}"
  puts "endpoint => #{endpoint}"
  puts "user => #{user}"
  puts 'pass => ********'
  # puts "pass => #{pass}" # uncomment it for full auth debugging
  puts "command => #{ENV['RD_EXEC_COMMAND']}"
  puts "newcommand => #{command}"
  puts ''

  puts 'ENV:'
  ENV.each do |k, v|
    puts "#{k} => #{v}" if v != pass && k != 'RD_CONFIG_PASS'
    puts "#{k} => ********" if v == pass || k == 'RD_CONFIG_PASS'
    # puts "#{k} => #{v}" if v == pass # uncomment it for full auth debugging
  end
end

def stderr_text(stderr)
  doc = REXML::Document.new(stderr)
  begin
    text = doc.root.get_elements('//S').map(&:text).join
    text.gsub(/_x(\h\h\h\h)_/) do
      code = Regexp.last_match[1]
      code.hex.chr
    end
  rescue
    return stderr
  end
end

case auth
when 'negotiate'
  winrm = WinRM::WinRMWebService.new(endpoint, :negotiate, user: user, pass: pass)
when 'kerberos'
  winrm = WinRM::WinRMWebService.new(endpoint, :kerberos, realm: realm)
when 'plaintext'
  winrm = WinRM::WinRMWebService.new(endpoint, :plaintext, user: user, pass: pass, disable_sspi: true)
when 'ssl'
  winrm = WinRM::WinRMWebService.new(endpoint, :ssl, user: user, pass: pass, disable_sspi: true)
else
  fail "Invalid authtype '#{auth}' specified, expected: kerberos, plaintext, ssl."
end

winrm.set_timeout(ENV['RD_CONFIG_WINRMTIMEOUT'].to_i) if ENV['RD_CONFIG_WINRMTIMEOUT']

case shell
when 'powershell'
  result = winrm.create_executor().run_powershell_script(command)
when 'cmd'
  result = winrm.create_executor().run_cmd(command)
when 'wql'
  result = winrm.wql(command)
end

result[:data].each do |output_line|
  eoutput = "#{eoutput}#{output_line[:stderr]}" if output_line.key?(:stderr)
  ooutput = "#{ooutput}#{output_line[:stdout]}" if output_line.key?(:stdout)
end

STDERR.print stderr_text(eoutput) if eoutput != ''
STDOUT.print ooutput
exit result[:exitcode] if result[:exitcode] != 0

# winrm.powershell(command) do |stdout, stderr|
#   STDOUT.print stdout
#   STDERR.print stderr
# end

# result = winrm.cmd(command)
# if result[:exitcode] != 0
#    result[:data].each do |output_line|
#          if output_line.has_key?(:stderr)
#                  STDOUT.print output_line[:stderr]
#                      end
#            end
# else
#    result[:data].each do |output_line|
#          if output_line.has_key?(:stdout)
#                  STDOUT.print output_line[:stdout]
#                      end
#            end
# end
