# Diverse Docker Funktionalitäten


## Volumes
In den bisherigen Use-Cases wurden *Docker-Volumes*, beispielsweise **mysqldb**, verwendet.
In diesem Kapitel soll ein wenig mit [Volumes](Volumes) umgegangen werden.

## Docker SDK

https://docs.docker.com/develop/sdk/examples/

## Jenkins -- 
Beispiel für Jenkins mit Docker:

### Variante 1:

Mit Docker in Docker ...

```
docker network create jenkins
docker volume create jenkins_home
docker volume create jenkins-docker-certs

docker container run --name jenkins-docker --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins_home:/var/jenkins_home \
  --volume "$HOME":/home \
  docker:dind
  
docker container run --name jenkins --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --volume jenkins_home:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  --volume "$HOME":/home \
  --publish 8080:8080 --publish 50000:50000 jenkins/jenkins:lts
 
```

### Variante 2:


```
docker run \
  -u root \
  -d \
  -p 8080:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --volume "$HOME":/home \
  --name jenkinsocean \
  jenkinsci/blueocean
  ```