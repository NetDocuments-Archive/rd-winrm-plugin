#!/usr/bin/ruby
gem 'winrm-fs', '= 1.0.2'
require 'winrm-fs'
auth = ENV['RD_CONFIG_AUTHTYPE']
nossl = ENV['RD_CONFIG_NOSSL'] == 'true' ? true : false
if ENV['RD_CONFIG_USER'] # allow empty (default) user (override used)
  user = ENV['RD_CONFIG_USER'].dup # for some reason this string is frozen, so we duplicate it
else
  user =''
end
if ENV['RD_CONFIG_PASS'] # allow empty (default) password (override used)
  pass = ENV['RD_CONFIG_PASS'].dup # for some reason this string is frozen, so we duplicate it
else
  pass = ''
end
host = ENV['RD_NODE_HOSTNAME']
port = ENV['RD_CONFIG_WINRMPORT']
transport = ENV['RD_CONFIG_WINRMTRANSPORT']
shell = ENV['RD_CONFIG_SHELL']
realm = ENV['RD_CONFIG_KRB5_REALM']
override = ENV['RD_CONFIG_ALLOWOVERRIDE']
if ENV['RD_CONFIG_WINRMTIMEOUT']
  timeout = ENV['RD_CONFIG_WINRMTIMEOUT'].to_i
else
  timeout = 60
end
host = ENV['RD_OPTION_WINRMHOST'] if ENV['RD_OPTION_WINRMHOST'] && (override == 'host' || override == 'all')
user = ENV['RD_OPTION_WINRMUSER'].dup if ENV['RD_OPTION_WINRMUSER'] && (override == 'user' || override == 'all')
pass = ENV['RD_OPTION_WINRMPASS'].dup if ENV['RD_OPTION_WINRMPASS'] && (override == 'user' || override == 'all')

file = ARGV[1]
dest = ARGV[2]
if auth == 'ssl'
  endpoint = "https://#{host}:#{port}/wsman"
else
  endpoint = "#{transport}://#{host}:#{port}/wsman"
end

# Wrapper to fix: "not setting executing flags by rundeck for 2nd file in plugin"
# # https://github.com/rundeck/rundeck/issues/1421
# remove it after issue will be fixed
if File.exist?("#{ENV['RD_PLUGIN_BASE']}/winrmexe.rb") && !File.executable?("#{ENV['RD_PLUGIN_BASE']}/winrmexe.rb")
  File.chmod(0764, "#{ENV['RD_PLUGIN_BASE']}/winrmexe.rb") # https://github.com/rundeck/rundeck/issues/1421
end
#---

# Wrapper for avoid unix style file copying then scripts run
# - not accept chmod call
# - replace rm -f into rm -force
# - auto copying renames file from .sh into .ps1, .bat or .wql in tmp directory
if %r{/tmp/.*\.sh}.match(dest)
  case shell
  when 'powershell'
    dest = dest.gsub(/\.sh/, '.ps1')
  when 'cmd'
    dest = dest.gsub(/\.sh/, '.bat')
  when 'wql'
    dest = dest.gsub(/\.sh/, '.wql')
  end
end
#---

# Build connection options
connections_opts = {
  endpoint: endpoint
}

connections_opts[:operation_timeout] = timeout

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

# Create session
winrm = WinRM::Connection.new(connections_opts)
file_manager = WinRM::FS::FileManager.new(winrm)
#---

## Upload file to host
begin
  file_manager.upload(file, dest)
rescue HTTPClient::ConnectTimeoutError => e #Capture Timeout on FileCopy (Server Offline)
  if ENV['RD_JOB_LOGLEVEL'] == 'DEBUG'
    STDERR.print "FileCopy failed due to Timeout:\n"
    STDERR.print "Exception Class: #{ e.class.name }\n"
    STDERR.print "Exception Message: #{ e.message }\n"
    STDERR.print "Exception Backtrace: #{ e.backtrace }\n"
    exit 1
  else
    STDERR.print "FileCopy failed due to Timeout: #{ e.class.name }--#{ e.message }\n"
    exit 1
  end
rescue WinRM::WinRMAuthorizationError => e #Capture WinRM Access error (Bad WinRM config)
  if ENV['RD_JOB_LOGLEVEL'] == 'DEBUG'
    STDERR.print "FileCopy failed due to WinRM Access failure:\n"
    STDERR.print "Exception Class: #{ e.class.name }\n"
    STDERR.print "Exception Message: #{ e.message }\n"
    STDERR.print "Exception Backtrace: #{ e.backtrace }\n"
    exit 1
  else
    STDERR.print "FileCopy failed due to WinRM Access failure: #{ e.class.name }--#{ e.message }\n"
    exit 1
  end
rescue => e
  if ENV['RD_JOB_LOGLEVEL'] == 'DEBUG'
    STDERR.print "FileCopy failed due to unhandled exception\n"
    STDERR.print "Exception Class: #{ e.class.name }\n"
    STDERR.print "Exception Message: #{ e.message }\n"
    STDERR.print "Exception Backtrace: #{ e.backtrace }\n"
    exit 1
  else
    STDERR.print "FileCopy failed due to unhandled exception: #{ e.class.name }--#{ e.message }\n"
    exit 1
  end
end
#---
