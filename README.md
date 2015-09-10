## Rd-WinRM-plugin
This is a [Rundeck Node Execution plugin][1] that uses WinRM to connect to Windows and execute commands. It uses the [WinRM for Ruby][2] Library to provide the WinRM implementation
[1]: http://rundeck.org/docs/manual/plugins.html#node-execution-plugins
[2]: https://github.com/WinRb/WinRM

Compatible with Rundeck 2.3.x+

## Features
Can run scripts, not only commands  
Can run PowerShell, CMD and WQL not only CMD  
Can avoid quoting problems (should be removed afrer core Rundeck fixes)  
Can copy files to windows

### Installation

Install Ruby:  
something like this: `apt-get install make ruby ruby-dev`  

Install following gems:  
`gem install winrm`  
`gem install winrm-fs`  
    
Download from the [releases page](https://github.com/vvchik/rd-winrm-plugin/releases).

Copy the `rd-winrm-plugin.zip` to the `libext/` directory for Rundeck.

Run `winrm quickconfig` as admin [Configuration the Remote Windows](https://technet.microsoft.com/en-us/magazine/ff700227.aspx) on Nodes

### Configuration
choose `WinRM Executivetor` as Default Node Executor  
and `WinRM File Copier` as Default Node File Copier   
Settings:  
`Kerberos Realm`  Put here fqdn of your realm in case your computer is part of AD domain  
`Username` Put here username for basic or ssl auth  
`Password` Put here username for basic or ssl auth  
`Auth type` choose here kerberos, plaintext or ssl  
`Shell` choose here powershell, cmd or wql  
`WinRM timeout` put here time in seconds (useful for long running commands)  

