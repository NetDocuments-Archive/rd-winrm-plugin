## Rd-WinRM-plugin
This is a [Rundeck Node Execution plugin][1] that uses WinRM to connect to Windows and execute commands. It uses the [WinRM for Ruby][2] Library to provide the WinRM implementation
[1]: http://rundeck.org/docs/plugins-user-guide/node-execution-plugins
[2]: https://github.com/WinRb/WinRM

Compatible with Rundeck 2.3.x+

## Features
Can run scripts, not only commands  
Can run PowerShell, CMD and WQL not only CMD  
Can avoid quoting problems (should be removed after core Rundeck fixes)  
Can copy files to windows  

### Installation

Install Ruby:  
Ubuntu: `apt-get install make ruby ruby-dev`  
CentOS/RHEL: `yum install make ruby ruby-devel`

Install following gems:  
`gem install winrm -v 1.8.1`  
`gem install winrm-fs -v 0.4.3`  

Download from the [releases page](https://github.com/NetDocuments/rd-winrm-plugin/releases).

Copy the `rd-winrm-plugin.zip` to the `libext/` directory for Rundeck. It must be named like `rd-winrm-plugin-x.x.x.zip`. There is no need to restart rundeck.

```bash
RD_WINRM='1.5.1'
curl https://github.com/NetDocuments/rd-winrm-plugin/archive/$RD_WINRM.zip -o /var/lib/rundeck/libext/rd-winrm-plugin-$RD_WINRM.zip
```

Before rundeck can run commands on windows nodes, [configure winrm](https://technet.microsoft.com/en-us/magazine/ff700227.aspx) from an administrative powershell window

    winrm quickconfig


### Configuration
Choose `WinRM Executor` as Default Node Executor  
and `WinRM File Copier` as Default Node File Copier   

Settings:  
`Kerberos Realm`  Put here fqdn of your realm in case your computer is part of AD domain  
`Username` (Removed, it will taken at node label) Put here username for negotiate, plaintext or ssl auth  
`Password` (Removed, it will taken at node label or using Password Storage)Put here password for negotiate, plaintext or ssl auth  
`Auth type` choose here negotiate, kerberos, plaintext or ssl  
`WinRM port` set port for winrm (Default: 5985/5986 for http/https)  
`Shell` choose here powershell, cmd or wql  
`WinRM timeout` put here time in seconds (useful for long running commands)  
`Password Storage` Put the password using the Key Storage

![](http://cl.ly/1S1D2C070Z1T/Screenshot%202016-01-05%2016.51.53.png)

### Special Behaviour
`Allow Override` parameter gives possibility to set hostname, username and password in job options, not in project. It can be used in case you need to quickly change hostnames (with dropdown list for example) or set username/pass on job level  

- If that parameter set to `hostname` you may use option variable with name `winrmhost` to set hostname
- If that parameter set to `user` you may use `winrmuser` and `winrmpass` to set username/pass
- If that parameter set to `all` you may use all these additional options
- If that parameter set to `none` these options in jobs will be ignored

### Limitations
- Scripts in c:/tmp with .sh extension will be renamed into .ps1, .bat or .wql
- Quotes behaviour can be strange (we trying to fix rundeck core strange behaviour, so our own also not perfect)
- WQL execution never been tested :)

### Troubleshooting
You may have some errors like ```WinRM::WinRMAuthorizationError```.  
You can run the following commands on the server to try to solve the problem:

```
winrm set winrm/config/client/auth @{Basic="true"}
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
```
You can read more about that on issue [#29](https://github.com/WinRb/WinRM/issues/29) on ruby WinRM page

### PR and reporting
PR is highly welcome, we using gitflow for our development process, so please, make them to develop branch.  
If you have some issue please describe steps to reproduce it

### License and Authors
Copyright 2015 NetVoyage Corporation (NetDocuments)

Author: [Volodymyr Babchynskyy](https://github.com/vvchik)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License
is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied. See the License for the specific language governing permissions and limitations under the License.
