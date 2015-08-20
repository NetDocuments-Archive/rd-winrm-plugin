#!/usr/bin/ruby
require 'winrm'
user = ENV['RD_CONFIG_USERNAME']
pass = ENV['RD_CONFIG_PASSWORD']
host = ENV['RD_NODE_HOSTNAME']
command = ENV['RD_EXEC_COMMAND']
endpoint = "http://#{host}:5985/wsman"

# command = 'ipconfig'

puts 'variables is:'
puts "endpoint is #{endpoint}"
puts "user is #{user}"
puts "pass is #{pass}"
puts "command is #{command}"
puts newcommand


winrm = WinRM::WinRMWebService.new(endpoint, :plaintext, user: user, pass: pass, :disable_sspi => true)
winrm.powershell(newcommand) do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end

