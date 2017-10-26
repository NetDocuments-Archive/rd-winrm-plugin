## Changelog
### [1.7.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.7.0)
- Update winrm and winrm-rf gems
- Rewrite of connection portion of script to support new features of these gems
- Add basic error handling to improve user friendliness of output
- Removed non functioning quote bug fix, Rundeck's documentation is an adequate fix until bug is resolved internally
- Added grouping to UI elements of plugin

### [1.6.2](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.6.2)
- Use Gem winrm 2.x which permit non-administrator session, see
https://github.com/WinRb/WinRM/issues/194
- Use Gem winrm-fs 1.x
- Allow WinRM transport protocol to be specified (HTTP/HTTPS) so
HTTPS can be selected without using 'ssl' authentication type.
- Allow empty defaut user and password at the project level, or
above, so only "overriding" in job options can be use instead

### [1.6.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.6.0)
Enables basic auth (GH-34)

### [1.5.1](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.5.1)
Add NTLM/Negotiate authentication type for WinRM File Copier

### [1.5.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.5.0)
Add NTLM/Negotiate authentication type [#19](https://github.com/NetDocuments/rd-winrm-plugin/issues/19)
Add check for required winrm/winrm-fs gem versions [#29](https://github.com/NetDocuments/rd-winrm-plugin/issues/29)

### [1.4.1](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.4.1)
Fix HTTPS with self-signed cert [#23](https://github.com/netdocuments/rd-winrm-plugin/issues/23)  
Added support https for ssl connections [#25](https://github.com/NetDocuments/rd-winrm-plugin/pull/25)  

### [1.4.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.4.0)
Fix credential leakage [#22](https://github.com/netdocuments/rd-winrm-plugin/issues/22)  
Change shell executions to use non deprecated methods [#24](https://github.com/netdocuments/rd-winrm-plugin/issues/24)  

### [1.3.2](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.3.2)
Fix for error output in case it is not in XML format

### [1.3.1](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.3.1)
Fixes in readme, fix for #3 (WinRM timeout defaults) and #2 (can't modify frozen string)

### [1.3.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.3.0)
Extension for copied script depends on context of script execution  

### [1.2.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.2.0)
Allow override feature and fix for [rundeck bug](https://github.com/rundeck/rundeck/issues/1421)  

### [1.1.1](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.1.1)
Sanitised passwords in debug mode  

### [1.1.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.1.0)
Added possibility to set port for winrm  

### [1.0.0](https://github.com/NetDocuments/rd-winrm-plugin/releases/tag/1.0.0)
Public release, debugging depends on debugging level on job  

### 0.9.0
Fixes in quotes cleanup behaviour, Fixes in quotes cleanup behaviour, trivial rubocop fixes  

### 0.8.0
WinRM timeout managed via config  

### 0.7.0
different shells support (powershell, cmd, wql)  

### 0.6.0
Different authentication types for winrm  

### 0.5.0
convert XML output into readable strings, Password as secure string, cleanup  

### 0.4.0
fix for unix style file manipulation in rundeck on windows, added timeout for log running command  

### 0.3.0
fix for strange rundeck behaviour with quotes  

### 0.2.0
added file copy feature  

### 0.1.0
initial commit  
