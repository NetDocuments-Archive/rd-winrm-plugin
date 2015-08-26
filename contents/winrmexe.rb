#!/usr/bin/ruby
require 'winrm'
user = ENV['RD_CONFIG_USERNAME']
pass = ENV['RD_CONFIG_PASSWORD']
host = ENV['RD_NODE_HOSTNAME']
command = ENV['RD_EXEC_COMMAND']
endpoint = "http://#{host}:5985/wsman"

# command = 'ipconfig'

newcommand = command.gsub(/'"'"'/, '')
# Wrapper for avoid unix style file copying in command run
# not accept chmod call
# replace rm -f into rm -force
# auto copying renames file from .sh into .ps1
# so in that case we should call file with ps1 extension
exit 0 if newcommand.include? 'chmod +x /tmp/'
newcommand = newcommand.gsub(/rm -f \/tmp\//, 'rm -force /tmp/') if newcommand.include? 'rm -f /tmp/'
newcommand = newcommand.gsub(/\.sh/, '.ps1') if /\/tmp\/.*\.sh/.match(newcommand)

puts 'variables is:'
#  puts "realm is #{realm}"
puts "endpoint is #{endpoint}"
puts "user is #{user}"
puts "pass is #{pass}"
puts "command is #{command}"
puts newcommand

winrm = WinRM::WinRMWebService.new(endpoint, :plaintext, user: user, pass: pass, :disable_sspi => true)
winrm.set_timeout(60000)
winrm.powershell(newcommand) do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end

