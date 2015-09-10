#!/usr/bin/ruby
require 'winrm'
auth = ENV['RD_CONFIG_AUTHTYPE']
user = ENV['RD_CONFIG_USER']
pass = ENV['RD_CONFIG_PASS'].dup # for some reason this string is frozen, so we duplicate it
host = ENV['RD_NODE_HOSTNAME']
shell = ENV['RD_CONFIG_SHELL']
realm = ENV['RD_CONFIG_KRB5_REALM']
command = ENV['RD_EXEC_COMMAND']
winrmtimeout = ENV['RD_CONFIG_WINRMTIMEOUT']
endpoint = "http://#{host}:5985/wsman"
output = ''

# Wrapper ro avoid strange and undocumented behavior of rundeck
# Should be deleted after rundeck fix
#  ''"'"'
command = command.gsub(/'"'"'' /, '\'')
command = command.gsub(/ ''"'"'/, '\'')
command = command.gsub(/ '"/, '"')
command = command.gsub(/"' /, '"')

# Wrapper for avoid unix style file copying in command run
# not accept chmod call
# replace rm -f into rm -force
# auto copying renames file from .sh into .ps1
# so in that case we should call file with ps1 extension
exit 0 if command.include? 'chmod +x /tmp/'
command = command.gsub(%r{rm -f /tmp/}, 'rm -force /tmp/') if command.include? 'rm -f /tmp/'
command = command.gsub(/\.sh/, '.ps1') if %r{/tmp/.*\.sh}.match(command)

# TODO: ENV['WINRM_LOG'] = '' or 'debug, info, warn, or error'

# if loglevel == 'debug'
  puts 'variables is:'
  puts "realm is #{realm}"
  puts "endpoint is #{endpoint}"
  puts "user is #{user}"
  puts "pass is #{pass}"
  puts "command is #{ENV['RD_EXEC_COMMAND']}"
  puts "newcommand is #{command}"

  puts 'ENV'
  ENV.each do |k, v|
    puts "#{k} => #{v}"
  end
#end

def stderr_text(stderr)
  doc = REXML::Document.new(stderr)
  text = doc.root.get_elements('//S').map(&:text).join
  text.gsub(/_x(\h\h\h\h)_/) do
    code = Regexp.last_match[1]
    code.hex.chr
  end
end

case auth
when 'kerberos'
  winrm = WinRM::WinRMWebService.new(endpoint, :kerberos, realm: realm)
when 'plaintext'
  winrm = WinRM::WinRMWebService.new(endpoint, :plaintext, user: user, pass: pass, disable_sspi: true)
when 'ssl'
  winrm = WinRM::WinRMWebService.new(endpoint, :ssl, user: user, pass: pass, disable_sspi: true)
else
  fail "Invalid authtype '#{auth}' specified, expected: kerberos, plaintext, ssl."
end

winrm.set_timeout(winrmtimeout.to_i) if winrmtimeout != ''

case shell
when 'powershell'
  result = winrm.powershell(command)
when 'cmd'
  result = winrm.cmd(command)
when 'wql'
  result = winrm.wql(command)
end
result[:data].each do |output_line|
  output = "#{output}#{output_line[:stderr]}" if output_line.key?(:stderr)
  STDOUT.print output_line[:stdout] if output_line.key?(:stdout)
end
STDERR.print stderr_text(output) if output != ''
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
