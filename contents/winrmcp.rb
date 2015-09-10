#!/usr/bin/ruby
require 'winrm-fs'
auth = ENV['RD_CONFIG_AUTHTYPE']
user = ENV['RD_CONFIG_USER']
pass = ENV['RD_CONFIG_PASS'].dup
host = ENV['RD_NODE_HOSTNAME']
realm = ENV['RD_CONFIG_KRB5_REALM']
winrmtimeout = ENV['RD_CONFIG_WINRMTIMEOUT']

file = ARGV[1]
dest = ARGV[2]
endpoint = "http://#{host}:5985/wsman"

dest = dest.gsub(/\.sh/, '.ps1') if %r{/tmp/.*\.sh}.match(dest)

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

file_manager = WinRM::FS::FileManager.new(winrm)

## upload file
file_manager.upload(file, dest)

## upload the entire contents of my_dir to c:/foo/my_dir
# file_manager.upload('/Users/sneal/my_dir', 'c:/foo/my_dir')

## upload the entire directory contents of foo to c:\program files\bar
# file_manager.upload('/Users/sneal/foo', '$env:ProgramFiles/bar')
