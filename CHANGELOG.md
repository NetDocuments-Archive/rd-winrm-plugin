## Changelog

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
