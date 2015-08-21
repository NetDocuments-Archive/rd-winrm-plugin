#!/usr/bin/ruby
require 'winrm-fs'
user = ENV['RD_CONFIG_USERNAME']
pass = ENV['RD_CONFIG_PASSWORD']
host = ENV['RD_NODE_HOSTNAME']
file = ARGV[1]
dest = ARGV[2]
endpoint = "http://#{host}:5985/wsman"

winrm = WinRM::WinRMWebService.new(endpoint, :plaintext, user: user, pass: pass, :disable_sspi => true)
file_manager = WinRM::FS::FileManager.new(winrm)

# upload file.txt from the current working directory
file_manager.upload(file, dest)

# upload the entire contents of my_dir to c:/foo/my_dir
#file_manager.upload('/Users/sneal/my_dir', 'c:/foo/my_dir')

# upload the entire directory contents of foo to c:\program files\bar
#file_manager.upload('/Users/sneal/foo', '$env:ProgramFiles/bar')

