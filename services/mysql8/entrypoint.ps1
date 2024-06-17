# 切换到目标工作目录
Set-Location -Path 'C:\mysql8\bin'

$PSDefaultParameterValues['Out-File:Encoding'] = 'default'
if ($env:MYSQL_ROOT_PASSWORD -eq $null){
    $env:MYSQL_ROOT_PASSWORD='zzy9527'
}
if ($env:MYSQL_DATA_DIR -eq $null){
    $env:MYSQL_DATA_DIR = 'C:\\mysql8\\data'
}

# Write-Output "[mysqld]" >> C:\my.ini
# 				"basedir=C:\\mysql-8.0.37-winx64" >> C:\my.ini
# 				"datadir=$env:MYSQL_DATA_DIR" >> C:\my.ini
# 				"port=3306" >> C:\my.ini
# 				"sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES" >> C:\my.ini

Write-Output "Initializing MySQL data directory..."
mysqld.exe --defaults-file=C:\myconf\my.ini --initialize-insecure

Write-Output "Installing MySQL service..."
mysqld.exe --install

Write-Output "Starting MySQL service..."
Start-Service mysql
Write-Output "Waiting for MySQL service to be fully up and running..."
Start-Sleep -Seconds 10  # 等待 10 秒，确保 MySQL 服务完全启动

# 使用 ALTER USER 命令来更新 root 用户的密码
Write-Output "Updating root user password..."
Write-Output "ALTER USER 'root'@'localhost' IDENTIFIED BY '$env:MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"
mysql.exe -u root --skip-password --execute="ALTER USER 'root'@'localhost' IDENTIFIED BY '$env:MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"

Write-Output "Creating new 'root' user with remote access..."
mysql.exe -u root -p"$env:MYSQL_ROOT_PASSWORD" --execute="CREATE USER 'root'@'%' IDENTIFIED BY '$env:MYSQL_ROOT_PASSWORD'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

Write-Output "Restarting MySQL service..."
Restart-Service mysql

Write-Output "MySQL setup completed. Keeping the container running..."
# ping localhost -t
