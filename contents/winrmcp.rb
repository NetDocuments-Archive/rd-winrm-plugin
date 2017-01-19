#!/usr/bin/ruby
gem 'winrm-fs', '= 1.0.1'
require 'winrm-fs'
auth = ENV['RD_CONFIG_AUTHTYPE']
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
override = ENV['RD_CONFIG_ALLOWOVERRIDE']
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
else
  fail "Invalid authtype '#{auth}' specified, expected: negotiate, kerberos, plaintext, ssl."
end

winrm = WinRM::Connection.new(connections_opts)

file_manager = WinRM::FS::FileManager.new(winrm)

## upload file
file_manager.upload(file, dest)

## upload the entire contents of my_dir to c:/foo/my_dir
# file_manager.upload('/Users/sneal/my_dir', 'c:/foo/my_dir')

## upload the entire directory contents of foo to c:\program files\bar
# file_manager.upload('/Users/sneal/foo', '$env:ProgramFiles/bar')
