#!/usr/bin/ruby
gem 'winrm', '= 2.2.3'
require 'winrm'
auth = ENV['RD_CONFIG_AUTHTYPE']
nossl = ENV['RD_CONFIG_NOSSL'] == 'true' ? true : false
if ENV['RD_CONFIG_USER'] # allow empy (default) password (override used)
  user = ENV['RD_CONFIG_USER'].dup # for some reason this string is frozen, so we duplicate it
else
  user =''
end
if ENV['RD_CONFIG_PASS'] # allow empy (default) password (override used)
  pass = ENV['RD_CONFIG_PASS'].dup # for some reason this string is frozen, so we duplicate it
else
  pass = ''
end
host = ENV['RD_NODE_HOSTNAME']
port = ENV['RD_CONFIG_WINRMPORT']
transport = ENV['RD_CONFIG_WINRMTRANSPORT']
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
  endpoint = "#{transport}://#{host}:#{port}/wsman"
end

# Wrapper to fix: "not setting executing flags by rundeck for 2nd file in plugin"
# # https://github.com/rundeck/rundeck/issues/1421
# remove it after issue will be fixed
if File.exist?("#{ENV['RD_PLUGIN_BASE']}/winrmcp.rb") && !File.executable?("#{ENV['RD_PLUGIN_BASE']}/winrmcp.rb")
  File.chmod(0764, "#{ENV['RD_PLUGIN_BASE']}/winrmcp.rb")
end
#---

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
#---

# Output DEBUG messages
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

# Build connection options
connections_opts = {
  endpoint: endpoint
}

connections_opts[:operation_timeout] = ENV['RD_CONFIG_WINRMTIMEOUT'].to_i if ENV['RD_CONFIG_WINRMTIMEOUT']

case auth
when 'negotiate'
  connections_opts[:transport] = :negotiate
  connections_opts[:user] = user
  connections_opts[:password] = pass
when 'kerberos'
  connections_opts[:transport] = :kerberos
  connections_opts[:realm] = realm
when 'plaintext'
  connections_opts[:transport] = :plaintext
  connections_opts[:user] = user
  connections_opts[:password] = pass
  connections_opts[:disable_sspi] = true
when 'ssl'
  connections_opts[:transport] = :ssl
  connections_opts[:user] = user
  connections_opts[:password] = pass
  connections_opts[:disable_sspi] = true
  connections_opts[:no_ssl_peer_verification] = nossl
else
  fail "Invalid authtype '#{auth}' specified, expected: negotiate, kerberos, plaintext, ssl."
end
#---

# Create and connect session
winrm = WinRM::Connection.new(connections_opts)
shell_session = nil
case shell
when 'powershell'
  begin
    shell_session = winrm.shell(:powershell)
    result = shell_session.run(command)
  rescue => e
    shell_session = nil
    if ENV['RD_JOB_LOGLEVEL'] == 'DEBUG'
      STDERR.print "Connection Failure: " + e.message + "\n"
      STDERR.print e.backtrace.inspect
      exit 1
    else
      STDERR.print "Connection Failure: " + e.message + "\n"
      exit 1
    end
  end
when 'cmd'
  begin
    shell_session = winrm.shell(:cmd)
    result = shell_session.run(command)
  rescue => e
    shell_session = nil
    if ENV['RD_JOB_LOGLEVEL'] == 'DEBUG'
      STDERR.print "Connection Failure: " + e.message + "\n"
      STDERR.print e.backtrace.inspect
      exit 2
    else
      STDERR.print "Connection Failure: " + e.message + "\n"
      exit 2
    end
  end
when 'wql'
  result = winrm.run_wql(command)
end
#---

# Organise output for return to Runeck
if shell_session != nil
  STDERR.print stderr_text(result.stderr) if result.stderr != ''
  STDOUT.print result.stdout
  exit result.exitcode if result.exitcode !=0
else # WQL
  STDOUT.print result
end
#---