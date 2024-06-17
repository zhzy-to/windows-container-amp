@echo off

REM Step 1: Install Docker Server
echo Installing Docker...
powershell -NoProfile -ExecutionPolicy Bypass -File ..\install-docker-ce.ps1
IF %ERRORLEVEL% NEQ 0 (
    echo Docker installation failed.
    exit /b 1
)

docker -v
IF %ERRORLEVEL% NEQ 0 (
    echo Docker installation failed.
    exit /b 1
)

echo Docker installation completed.

REM Step 2: Import the environment image
echo Importing Docker image...
docker load -i ..\windows-docker-compose-cms.tar

IF %ERRORLEVEL% NEQ 0 (
     echo Docker image import failed.
     exit /b 1
 )

echo Docker image import completed.


REM Step 3: Start the container and mount the directory
REM Get the full path of the current directory
set "current_dir=%cd%"

REM Get the parent directory path
for %%i in ("%current_dir%") do set "parent_dir=%%~dpi"

REM Remove the backslash at the end of the path
set "parent_dir=%parent_dir:~0,-1%"

echo parent directory path: %parent_dir%

REM Start the container
docker run --isolation=hyperv --name cms-container -d -p 80:80 -p 443:443 -p 3306:3306 -e MYSQL_ROOT_PASSWORD="abc123456" -v "%parent_dir%\data\mysql:C:\mysql8\data" -v "%parent_dir%\conf\mysql:C:\myconf" -v "%parent_dir%\www:C:\www" -v "%parent_dir%\log\apache:C:\Apache24\logs" -v "%parent_dir%\conf\apache:C:\Apache24\conf" windows-docker-compose-cms:latest

IF %ERRORLEVEL% NEQ 0 (
     echo Docker container start failed.
     exit /b 1
)

echo Docker container started successfully.

pause