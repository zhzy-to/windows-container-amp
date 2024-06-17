# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

LABEL Description="Apache-PHP" Vendor1="Apache Software Foundation" Version1="2.4.38" Vendor2="The PHP Group" Version2="5.6.40"

ENV MYSQL_ROOT_PASSWORD=123456..

COPY services/VC_redist.x64_2015-2019.exe c:/vcredist_x64.exe
RUN powershell -Command `
    $ErrorActionPreference = 'Stop'; `
    start-Process c:/vcredist_x64.exe -ArgumentList '/quiet' -Wait ; `
    Remove-Item c:/vcredist_x64.exe -Force

# MYSQL
# https://cdn.mysql.com/archives/mysql-8.3/mysql-8.3.0-winx64.zip
COPY services/mysql8/mysql-8.0.37-winx64.zip C:/mysql.zip

RUN powershell -Command `
    $ErrorActionPreference = 'Stop'; `
    Expand-Archive -Path C:/mysql.zip -DestinationPath c:/ ; `
    new-item -Type Directory c:\myconf -Force ; `
    Remove-Item C:/mysql.zip -Force

COPY services/mysql8/my.ini c:/myconf/my.ini
RUN SETX /M PATH "%PATH%;C:\mysql8\bin"

COPY services/mysql8/entrypoint.ps1 C:/entrypoint.ps1

#ENTRYPOINT [ "powershell", ".\\entrypoint.ps1"]
ENTRYPOINT [ "powershell", "C:/entrypoint.ps1"]

# Copy Apache binaries
#
COPY services/apache24/httpd-2.4.59-win64-VS17.zip c:/apache.zip
RUN powershell -Command `
    $ErrorActionPreference = 'Stop'; `
    Expand-Archive -Path c:/apache.zip -DestinationPath c:/ ; `
    Remove-Item c:/apache.zip -Force

# PHP
# https://windows.php.net/download#php-8.1
COPY services/php81/php-8.1.29-Win32-vs16-x64.zip c:/php.zip
RUN powershell -Command `
    $ErrorActionPreference = 'Stop'; `
    Expand-Archive -Path c:/php.zip -DestinationPath c:/php ; `
    Remove-Item c:/php.zip -Force

RUN SETX /M PATH "%PATH%;C:\php"

COPY services/php81/php.ini c:/php/php.ini

# Configure Apache and PHP
RUN powershell -Command `
	$ErrorActionPreference = 'Stop'; `
	Remove-Item c:\Apache24\conf\httpd.conf ; `
	new-item -Type Directory c:\www -Force ; `
	Add-Content -Value "'<?php phpinfo() ?>'" -Path c:\www\index.php


# Copy custom httpd.conf
COPY services/apache24/httpd.conf /apache24/conf

#WORKDIR /Apache24/bin
WORKDIR /www

EXPOSE 80
EXPOSE 443

#CMD ["powershell.exe"]

# 在Windows环境中启动Apache HTTP Server，而不将其作为服务运行。这通常用于调试或测试目的
# CMD /Apache24/bin/httpd.exe -w

RUN powershell -Command `
    "C:\Apache24\bin\httpd.exe" -k install -n apache; `
    Start-Service -Name apache; `
    Stop-Service apache

# CMD ["powershell", "-NoExit", "-Command", "ping localhost -t"]

# 前台运行
# 在Windows环境中启动Apache HTTP Server，而不将其作为服务运行。这通常用于调试或测试目的
# CMD ["C:\\Apache24\\bin\\httpd.exe", "-DFOREGROUND"]

# Start-Process 命令来启动 Apache，并确保它在前台运行。-NoNewWindow 确保进程不会在新窗口中启动，-Wait 确保 PowerShell 会等待进程完成
# Start-Sleep -Seconds 2; 这行命令添加了一个2秒的等待时间，确保 Apache 有足够的时间启动。
# 日志输出: Get-Content 'C:\\Apache24\\logs\\error.log' -Wait
CMD ["powershell", "-Command", "Start-Process 'C:\\Apache24\\bin\\httpd.exe' -NoNewWindow -Wait; Start-Sleep -Seconds 2; Get-Content 'C:\\Apache24\\logs\\error.log' -Wait"]