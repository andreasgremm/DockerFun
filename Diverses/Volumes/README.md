# Docker-Volumes und ihr Handling
In den bisherigen Use-Cases wurden *Docker-Volumes*, beispielsweise **mysqldb**, verwendet.
In diesem Kapitel soll ein wenig mit Volumes umgegangen werden.

Hierzu generieren wir uns ein neues Volume.

```
docker volume create tempvolume
```

Wir zeigen unsere bestehenden Volumes an:

```
docker volume ls
DRIVER              VOLUME NAME
local               e0440bf36978c93f42eb999468cb9d3876ebdec8fed0db744bf053d6c29bc233
local               f59ce3ccbca813bf4ca3f0943fd18a8cdfddf5c05d3f079517da2c69edcda19d
local               mysqldb
local               portainer_data
local               tempvolume
```

Unser *tempvolume* könen wir nun in Containern verwenden, indem wir beim Start des Containers das Volume an eine Stelle in das Dateisystem des laufenden Containers **mounten**.

Test mittels des *busybox* image:

```
docker run --rm -it --mount source=tempvolume,destination=/Daten busybox
/ # ls /Daten
/ # mount | grep Daten
   /dev/sda1 on /Daten type ext4 (rw,relatime,data=ordered)

/ # echo "Hello World" >/Daten/hello.txt
/ # ls /Daten
   hello.txt
   
/ # exit
```
Im obigen Beispiel sehen wir, dass 

* unser neues Volume gemountet ist (*mount*)
* dieses noch keine Dateien enthält (1. *ls*)
* wir aber Dateien dort erzeugen können (*echo*, 2. *ls*)

## Vorbereitung 
Um Daten aus unserem Rechner in das Volume zu kopieren oder aus dem Volume herauszukopieren kann der **docker cp** Befehl genutzt werden. Hierzu benötigen wir einen Container, da **docker cp** Daten eines Containers nutzt.


### Alternative 1: Aufbau eines minimalen Containers
Im Folgenden wird ein minimaler Container erzeugt mit dem das Volume bearbeitet werden kann.

Folgendes Dockerfile erzeugt mit dem Befehl ```docker build -t nothing .```ein minimales Image mit dem Namen *nothing*:

```
FROM scratch
CMD
```

Listen wir das Image auf, sehen wir die minimalistische Größe:

```
docker image ls
   REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
   nothing                   latest              02728f7444c2        About an hour ago   0B
```
Aus dem Image erzeugen wir einen Container mit dem Namen *temp* und mounten unser Volume *tempvolume*:

```
docker container create --name temp --mount source=tempvolume,destination=/Daten nothing
```

### Alternative 2: Nutzung eines bestehenden Image

```
docker container create --name temp --mount source=tempvolume,destination=/Daten busybox
```

## Kopieren von Daten 

Jetzt können mittels **docker cp** Daten in unser Volume hinein- und herauskopiert werden:
(Anmerkung:*meinDatenVerzeichnis* gegen ein real existierendes Verzeichnis austauschen

```
docker cp meinDatenVerzeichnis temp:/Daten                                          # Kopiere Verzeichnis zum Volume
docker run --rm -it --mount source=tempvolume,destination=/Daten busybox ls /Daten  # Überprüfen der Copy-Aktion

docker cp temp:/Daten/meinDatenVerzeichnis neuesVerzeichnis                         # Kopiere Verzeichnis vom Volume

docker cp temp:/Daten/hello.txt meinHello.txt                                       # Kopieren einzelner Dateien
```
