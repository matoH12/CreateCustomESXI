# Create Custom install ISO file with external driver or software
This script you can use for create custom install iso from vmware where you import custom driver or software.

Install powershell package
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
Install-Module -Name VMware.PowerCLI -SkipPublisherCheck


Using script


```
.\createCustomEsxiInstallerImageV2.ps1 [path to esxi depot.zip] [path to folder with external package]
.\createCustomEsxiInstallerImageV2.ps1 C:\Users\Administrator\Downloads\ESXi670-201912001.zip C:\Users\Administrator\Downloads\Cisco\ 
```
Choose ESXI version from imported software depport:

![alt text](https://github.com/matoH12/CreateCUstomESXI/blob/main/Chose-esxi.PNG?raw=true)


Choose additional SW imported from directory:

![alt text](https://github.com/matoH12/CreateCUstomESXI/blob/main/chose-sw.PNG?raw=true)

Exported ISO file:

![alt text](https://github.com/matoH12/CreateCUstomESXI/blob/main/export.PNG?raw=true)



Example usage
https://virtualall.sk/vmware/vsphere/vmware-esxi-vytvorenie-vlastneho-instalacneho-media/
