#!/usr/bin/ruby
gem 'winrm-fs', '= 0.4.3'
require 'winrm-fs'

auth = ENV['RD_CONFIG_AUTHTYPE']
user = ENV['RD_NODE_USERNAME'] #take the username from node
pass = ENV['RD_CONFIG_PASSWORDSTORAGEPATH'].dup  #take the password from password storage path
host = ENV['RD_NODE_HOSTNAME']
port = ENV['RD_CONFIG_WINRMPORT']
shell = ENV['RD_CONFIG_SHELL']
realm = ENV['RD_CONFIG_KRB5_REALM']
command = ENV['RD_EXEC_COMMAND']
override = ENV['RD_CONFIG_ALLOWOVERRIDE']
host = ENV['RD_OPTION_WINRMHOST'] if ENV['RD_OPTION_WINRMHOST'] && (override == 'host' || override == 'all')
user = ENV['RD_OPTION_WINRMUSER'].dup if ENV['RD_OPTION_WINRMUSER'] && (override == 'user' || override == 'all')
pass = ENV['RD_OPTION_WINRMPASS'].dup if ENV['RD_OPTION_WINRMPASS'] && (override == 'user' || override == 'all')
no_ssl_peer_verification=ENV['RD_CONFIG_NOSSLPV']


file = ARGV[1]
dest = ARGV[2]
if auth == 'ssl'
  endpoint = "https://#{host}:#{port}/wsman"
else
  endpoint = "http://#{host}:#{port}/wsman"
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

case auth
when 'negotiate'
  winrm = WinRM::WinRMWebService.new(endpoint, :negotiate, user: user, pass: pass)
when 'kerberos'
  winrm = WinRM::WinRMWebService.new(endpoint, :kerberos, realm: realm)
when 'plaintext'
  winrm = WinRM::WinRMWebService.new(endpoint, :plaintext, user: user, pass: pass, disable_sspi: true)
when 'ssl'
  winrm = WinRM::WinRMWebService.new(endpoint, :ssl, user: user, pass: pass, disable_sspi: true, :no_ssl_peer_verification => no_ssl_peer_verification)
else
  fail "Invalid authtype '#{auth}' specified, expected: kerberos, plaintext, ssl."
end

winrm.set_timeout(ENV['RD_CONFIG_WINRMTIMEOUT'].to_i) if ENV['RD_CONFIG_WINRMTIMEOUT']

file_manager = WinRM::FS::FileManager.new(winrm)

## upload file
file_manager.upload(file, dest)

## upload the entire contents of my_dir to c:/foo/my_dir
# file_manager.upload('/Users/sneal/my_dir', 'c:/foo/my_dir')

## upload the entire directory contents of foo to c:\program files\bar
# file_manager.upload('/Users/sneal/foo', '$env:ProgramFiles/bar')
