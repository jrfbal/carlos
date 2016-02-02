REM Variables.  
SETLOCAL EnableDelayedExpansion  
SET FtpSiteName=CometFtp
SET StorageName=cometftp
SET StorageKey=Iwio79jS2I9qq2D3Iyk4YV0SfEayXf54LtUBXmTBzi7ASlimcoSdNp300ODpS3V3IlGmfISNXiFUukh4du0YRQ
SET ShareName=ftp
SET PublicPort=2501
SET DynamicPortFirst=10000
SET DynamicPortLast=10001
SET DynamicPortRange=%DynamicPortFirst%-%DynamicPortLast%
SET PublicIP=104.45.13.151

REM Install FTP.  
START /w pkgmgr /iu:IIS-WebServerRole;IIS-FTPSvc;IIS-FTPServer;IIS-ManagementConsole

mkdir C:\Support
REM Add user.  
net user %StorageName% /delete  
net user %StorageName% %StorageKey% /add

REM Configuring FTP site.  
pushd %windir%\system32\inetsrv  
appcmd add site /name:%FtpSiteName% /bindings:ftp://*:%PublicPort% /physicalpath:"C:\Support"  
REM appcmd set vdir /vdir.name:"%FtpSiteName%/" /userName:%StorageName% /password:%StorageKey%==
appcmd set config -section:system.applicationHost/sites /[name='%FtpSiteName%'].ftpServer.security.ssl.controlChannelPolicy:"SslAllow"  
appcmd set config -section:system.applicationHost/sites /[name='%FtpSiteName%'].ftpServer.security.ssl.dataChannelPolicy:"SslAllow"  
appcmd set config -section:system.applicationHost/sites /[name='%FtpSiteName%'].ftpServer.security.authentication.basicAuthentication.enabled:true  
appcmd set config %FtpSiteName% /section:system.ftpserver/security/authorization /-[users='*'] /commit:apphost  
appcmd set config %FtpSiteName% /section:system.ftpserver/security/authorization /+[accessType='Allow',permissions='Read,Write',roles='',users='*'] /commit:apphost  
appcmd set config /section:system.ftpServer/firewallSupport /lowDataChannelPort:%DynamicPortFirst% /highDataChannelPort:%DynamicPortLast%  /commit:apphost
appcmd set config -section:system.applicationHost/sites /siteDefaults.ftpServer.firewallSupport.externalIp4Address:"%PublicIP%" /commit:apphost

REM Configure firewall.  
netsh advfirewall firewall add rule name="FTP Public Port" dir=in action=allow protocol=TCP localport=%PublicPort%  
REM Restart the FTP service.  
net stop ftpsvc  
net start ftpsvc

REM net use Z: \\cometftp.file.core.windows.net\ftp\QM /u:cometftp Iwio79jS2I9qq2D3Iyk4YV0SfEayXf54LtUBXmTBzi7ASlimcoSdNp300ODpS3V3IlGmfISNXiFUukh4du0YRQ==



REM xcopy /t /e "C:\inetpub\ftproot" "C:\foldertemplate"