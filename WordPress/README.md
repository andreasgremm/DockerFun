# WordPress

WordPress ist ein freies Content-Management-System. Es wurde ab 2003 von Matthew Mullenweg als Software für Weblogs programmiert und wird als Open-Source-Projekt ständig weiterentwickelt. WordPress ist das am weitesten verbreitete System zum Betrieb von Webseiten mit ca. 50 % Anteil an allen CMS bzw. 32 % Anteil aller Webseiten[3].

## Use Case: WordPress als Service

Für unseren Use-Case wollen wir [Docker-Compose](https://docs.docker.com/compose/) verwenden, um eine reproduzierbare, abgeschottete Umgebung für WordPress zu erzeugen und diese Basis auch für andere Anwendungsfälle nutzen zu können.
Für die Realisierung benötigen wir drei Docker-Images.

* [MySql Datenbank](https://hub.docker.com/_/mysql) als Datenquelle für die Erzeugung eines oder mehrerer APIs
* [PhpMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin/) für die angenehmere Verwaltung der MySql-Datenbank
* [WordPress](https://hub.docker.com/_/wordpress/)

### Allgemeine Vorbereitungen 
Um diesen Use Case durchzuführen, benötigen wir natürlich eine Installation von Docker.
Hierzu wird die Variante [**Docker CE**](https://docs.docker.com/install/) für das zur Verfügung stehende Betriebssystem installiert. 
Sollte die Installation auf der zur Verfügung stehenden Maschine so nicht möglich sein, gibt es natürlich auch immer die Möglichkeit in einer Virtualisierungsumgebung z.B: VMWare Workstation oder [VirtualBox](https://www.virtualbox.org/) zu arbeiten.

### Vorbereitung für Docker-Compose
In diesem Use-Case sollen verschiedene Automatismen von Docker dargestellt werden, auf die in Use-Case 1 noch nicht eingegangen wurde.

Im ersten Use-Case haben wir per **docker pull** die Images aus dem Repository in die lokale Docker-Umgebung geladen. Dieses wird bei der Ausführung von **docker run** automatisch erledigt, wenn das Image entweder noch nicht lokal vorhanden ist oder sich das Image im Repository verändert hat.

Ebenfalls noch nicht betrachtet haben wir die Trennung von Anwendungen innerhalb der Docker-Umgebung voneinander. Dieses betrifft sowohl das Netzwerk als auch Daten (Volumes).

Wie im obigen Link zu Docker-Compose beschrieben, wird eine Datei docker-compose.yml benötigt um mehrere Docker Container gleichzeitig zu starten.

Ein Beispiel für WordPress findet sich [hier](https://docs.docker.com/compose/wordpress/).

Sobald die Beispieldatei in ein Verzeichnis auf dem Docker-Rechner kopiert wurde und innerhalb des Verzeichnis der Befehl ```docker-compose up -d```ausgeführt wird, kann über den Webbrowser auf dem Port 8000 die WordPress Instanz erreicht werden.

Der Befehl ```docker-compose down --volume```beendet die Installation und löscht die erzeugten volumes.

### WordPress Service

Eine etwas [komplexere](https://gist.github.com/bradtraversy/faa8de544c62eef3f31de406982f1d42) Komposition des docker-compose.yaml ermöglicht die Darstellung einer weiteren Funktionlitäten, der Trennung des Service in eine separate Netzwerkumgebung.

Legen wir folgende docker-compose.yaml Datei (kopieren & einfügen) in ein neues Verzeichnis auf unserem Docker-Rechner.

```
version: '3'

services:
  # Database
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    networks:
      - wpsite
  # phpmyadmin
  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
      - '8080:80'
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: password 
    networks:
      - wpsite
  # Wordpress
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - '8000:80'
    restart: always
    volumes: ['./:/var/www/html']
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
    networks:
      - wpsite
networks:
  wpsite:
volumes:
  db_data:
```

Im Folgenden wollen wir den in der docker-compose.yaml definierten Service starten und uns die Docker-Umgebung bezüglich der Trennung des neuen Service von der allgemeinen Ablaufumgebung anschauen.

Was lernen wir aus der Ausgabe folgender Befehle?

```
docker volume ls
docker network ls
docker-compose up -d
docker volume ls
docker network ls
```
Es ist ein neues Netzwerk erstellt worden, der Netzwerk-Name besteht aus dem aktuellen Verzeichnisnamen mit dem Anhängsel wpsite.

Mit ```docker network inspect bridge``` und ```docker network inspect <neuer Netzwerkname>``` lassen sich die Netzwerkattribute anzeigen. Beide Netze haben unterschiedliche IP-Adressen und sind voneinander getrennt. 

Wie im vorhergehenden einfacheren WordPress-Beispiel hat auch das Volume den Verzeichnisnamen als Prefix zum Volume-Namen bekommen.

Am Ende räumen wir mittels ```docker-compose down --volume``` die Umgebung wieder auf.

Wollen wir die erstellte Umgebung nicht komplett löschen, können die Container mit ```docker-compose stop``` angehalten und später mit ```docker-compose start``` wieder aktiviert werden.
