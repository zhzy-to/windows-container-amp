
#### installation steps


##### Run CMD as Administrator
- 1.Enable Hyper-V and Containers
```shell

# Will restart the system

windows-docker-compose\check_env.bat
```



- 2.Exporting an Image
```shell
docker build --isolation=hyperv -t windows-docker-compose-cms:latest . --no-cache

docker save -o windows-docker-compose-cms.tar windows-docker-compose-cms:latest
```




- 3.Install DockerCE import image startup
```shell
# After success, access the local localhost address

windows-docker-compose\install_and_run.bat

```




#### docker build

- 1
```shell
docker load -i servercore-ltsc2022.tar 
```

- 2
```shell
docker build --no-cache --isolation=hyperv -t apache-php-mysql:latest .
```

- 3
```shell
docker run --isolation=hyperv \
  --name apache-php-mysql \
  -d \
  -p 80:80 \
  -p 443:443 \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD="xxxxxx" \
  -v ./data/mysql:c:/mysql8/data \
  -v ./conf/mysql:c:/myconf \
  -v ./www:c:/www \
  -v ./log/apache:c:/Apache24/logs \
  -v ./conf/apache:c:/Apache24/conf \
  apache-php-mysql:latest
```


#### Start the container through the local image

```shell

docker run --isolation=hyperv \
  --name cms-container \
  -d \
  -p 80:80 \
  -p 443:443 \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD="abc123456" \
  -v C:\Dev\windows-docker-compose\data\mysql:c:/mysql8/data \
  -v C:\Dev\windows-docker-compose\conf\mysql:c:/myconf \
  -v C:\Dev\windows-docker-compose\www:c:/www \
  -v C:\Dev\windows-docker-compose\log\apache:c:/Apache24/logs \
  -v C:\Dev\windows-docker-compose\conf\apache:c:/Apache24/conf \
  windows-docker-compose-cms:latest
  

docker run --isolation=hyperv --name cms-container -d -p 80:80 -p 443:443 -p 3306:3306 -e MYSQL_ROOT_PASSWORD="abc123456" -v C:\Dev\windows-docker-compose\data\mysql:C:\mysql8\data -v C:\Dev\windows-docker-compose\conf\mysql:C:\myconf -v C:\Dev\windows-docker-compose\www:C:\www -v C:\Dev\windows-docker-compose\log\apache:C:\Apache24\logs -v C:\Dev\windows-docker-compose\conf\apache:C:\Apache24\conf windows-docker-compose-cms:latest


docker exec -it cms-container powershell


docker restart cms-container

docker rm cms-container


```