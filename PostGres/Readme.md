# PostGreSQL
Auf dem [Docker Hub](https://hub.docker.com/_/postgres) liegt die Beschreibung und das Image.

```
docker pull postgres
```

Für die Datenbank wird ein Docker-Volume erzeugt:

```
docker volume create postgresdb
```

Der erstmalige Start erfolgt mit:
Der Default-User ist **postgres**.

```

docker run --name test-postgres -e POSTGRES_PASSWORD=mysecretpassword -d \
   --mount 'src=postgresdb,dst=/var/lib/postgres' \
   postgres
```

# Pgadmin4

[Pgadmin4](https://pgadmin.org) ist ähnlich wie phpMyAdmin eine Managementoberfläche.

```
docker pull dpage/pgadmin4	
```

Der einfache Start erfolgt mit:

```
docker run -p 80:80 \
   -e PGADMIN_DEFAULT_PASSWORD=SuperSecret \
   -e PGADMIN_DEFAULT_EMAIL=user@email.de \
   -e PGADMIN_DISABLE_POSTFIX=yes \
   --link test-postgres:db -d \
   dpage/pgadmin4
```

Der Benutzername für pgAdmin4 ist die Email-Adresse!

Nach dem Login kann ein neuer Server angelegt werden.

* Connection: db
* User: postgres
* Password: mysecretpassword

Anschliessend können Datenbanken + Tabellen entsprechend angelegt werden.  Anbei einfache Beispiele:

```
-- Database: andreas

-- DROP DATABASE andreas;

CREATE DATABASE andreas
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
    
-- Table: public.Adresse

-- DROP TABLE public."Adresse";

CREATE TABLE public."Adresse"
(
    "ID" integer NOT NULL DEFAULT nextval('"Adresse_ID_seq"'::regclass),
    "Vorname" character varying COLLATE pg_catalog."default" NOT NULL,
    "Nachname" character varying COLLATE pg_catalog."default" NOT NULL,
    "Strasse" character varying COLLATE pg_catalog."default" NOT NULL,
    "Ort" character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Adresse_pkey" PRIMARY KEY ("ID")
)

TABLESPACE pg_default;

ALTER TABLE public."Adresse"
    OWNER to postgres;
```



# CA Live Api Creator

```
docker pull caliveapicreator/5.4.00
docker run -p 8080:8080 -d --link=test-postgres:db --name liveapicreator caliveapicreator/5.4.00
```

Eine genauere Anleitung liegt unter [Layer7APICreator](https://github.com/andreasgremm/DockerFun/tree/master/Layer7APICreator). 

Dort wird die Nutzung einer MySQL Datenbank beschrieben. Bei Postgres muss noch das Schema angegeben werden, dieses ist ohne weitere Veränderungen bei der Anlage der Datenbank/Tabellen "public".

Nachfolgend die Ansicht des "RestLab" mit Darstellung der Strukturen im "Request-Body". Im Beispiel wird auch ein von syntaktischer Fehler angezeigt.

![Rest-Lab Darstellung](C:\Users\Gremma\Documents\DockerFun\PostGres\Post_New_Entry.png)



# Das Gesamtkonstrukt in Docker

Für ein funktionsfähiges Konstrukt sollten alle drei Container in Docker laufen.

```
andreas@G02DEXN02069:~$ docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED       STATUS       PORTS                         NAMES
c31294d372e0   caliveapicreator/5.4.00   "catalina.sh run"        2 hours ago   Up 2 hours   0.0.0.0:8080->8080/tcp        liveapicreator
7be1b6fec163   dpage/pgadmin4            "/entrypoint.sh"         3 hours ago   Up 3 hours   0.0.0.0:80->80/tcp, 443/tcp   focused_jang
de8006de3664   postgres                  "docker-entrypoint.s…"   4 hours ago   Up 4 hours   5432/tcp                      test-postgres
```



# Aufruf des API

Ausserhalb des Live API Creators lässt das API natürlich auch aufrufen. Im Menu "RestLab" werden über den Button **How to call this API** eine Liste exemplarisch dargestellt. Über **copy + paste** können diese Kommandos dann direkt genutzt werden.



```
andreas@G02DEXN02069:~$ curl -H "Authorization: CALiveAPICreator VpX1taRyeZUPBm29bBvR:1" "http://localhost:8080/rest/default/fwuuu/v1/main:Adresse"
[
  {
    "ID": 1,
    "Vorname": "Wilfried",
    "Nachname": "Cleres",
    "Strasse": "Demoweg 2",
    "Ort": "4711 Demostadt",
    "@metadata": {
      "href": "http://localhost:8080/rest/default/fwuuu/v1/main:Adresse/1",
      "checksum": "A:cae2e260b952291e",
      "links": [
      ]
    }
  },
  {
    "ID": 2,
    "Vorname": "Andreas",
    "Nachname": "Gremm",
    "Strasse": "Demoweg 1",
    "Ort": "4711 Demostadt",
    "@metadata": {
      "href": "http://localhost:8080/rest/default/fwuuu/v1/main:Adresse/2",
      "checksum": "A:122c7c237edd9c09",
      "links": [
      ]
    }
  }
]
andreas@G02DEXN02069:~$
```





