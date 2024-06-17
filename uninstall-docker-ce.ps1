# 确保以管理员身份运行
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Please run this script as an Administrator."
    exit
}

# 查看所有镜像
Write-Output "Listing all Docker images..."
docker ps

# 停止正在运行的容器
Write-Output "Stopping all running Docker containers..."
docker stop $(docker ps -q)

# 删除所有容器
Write-Output "Removing all Docker containers..."
docker rm $(docker ps -aq)

# 清空所有
Write-Output "Pruning Docker system..."
docker system prune -a -f

# 停止 Docker 服务
Write-Output "Stopping Docker service..."
Stop-Service -Name docker -ErrorAction SilentlyContinue

# 取消注册 Docker 服务
Write-Output "Unregistering Docker service..."
& dockerd --unregister-service

# 删除 Docker 数据目录
Write-Output "Deleting Docker data directory..."
Remove-Item -Path C:\ProgramData\docker -Recurse -Force -ErrorAction SilentlyContinue

# 检查 Docker 服务是否仍然存在
Write-Output "Checking Docker service status..."
Get-Service -Name "docker" -ErrorAction SilentlyContinue

# 查找 Docker 可执行文件路径
Write-Output "Locating Docker executable..."
$dockerPaths = where.exe docker

# 删除 Docker 可执行文件
foreach ($dockerPath in $dockerPaths) {
    Write-Output "Deleting Docker executable at $dockerPath..."
    Remove-Item -Path $dockerPath -Force -ErrorAction SilentlyContinue
}

Write-Output "Docker cleanup has been successfully completed."
