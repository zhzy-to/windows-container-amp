@echo off
set "thisDir=%~dp0"
set "parentDir=%thisDir:~0,-1%"  :: 移除尾部的反斜杠（\）
set "parentDir=%parentDir%\.."    :: 添加上级目录的路径

set "tarFilePath=%parentDir%\windows-docker-compose-cms.tar"

echo "%tarFilePath%"

@REM REM Step 2: 导入环境镜像
@REM echo Importing Docker image...
@REM docker load -i windows-docker-compose-cms.tar
@REM IF %ERRORLEVEL% NEQ 0 (
@REM     echo Docker image import failed.
@REM     exit /b 1
@REM )
@REM echo Docker image import completed.
@REM
@REM REM Step 3: 启动容器并挂载目录
@REM echo Starting Docker container...
@REM
@REM REM 获取当前目录位置
@REM setlocal
@REM set "CURRENT_DIR=%cd%"
@REM
@REM docker run -d -v "%CURRENT_DIR%\my-volume:/path/in/container" my-image
@REM IF %ERRORLEVEL% NEQ 0 (
@REM     echo Docker container start failed.
@REM     exit /b 1
@REM )
@REM echo Docker container started successfully.
@REM
@REM REM End of script
@REM echo Script completed.
@REM pause