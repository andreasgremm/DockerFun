# Layer7 Live API Creator


## Use Case: Layer7 Live API Creator
[Layer7 Live API Creator] (https://www.ca.com/de/products/ca-live-api-creator.html)  ist eine Lösung von CA Technolgies für die "On the Fly" Erzeugung von HTTP/RestFul Schnittstellen auf Basis von Datenquellen. Beispielsweise SQL/NoSQL Datenbanken, CSV Dateien u.v.m..

Für unseren Use-Case wollen wir Docker verwenden, um eine reproduzierbare Umgebung zu erzeugen und diese Basis auch für andere Anwendungsfälle nutzen zu können.
Für die Realisierung benötigen wir drei Docker-Images.

* [MySql Datenbank] (https://hub.docker.com/_/mysql) als Datenquelle für die Erzeugung eines oder mehrerer APIs
* [PhpMyAdmin] (https://hub.docker.com/r/phpmyadmin/phpmyadmin/) für die angenehmere Verwaltung der MySql-Datenbank
* [Layer7 Live API Creator] (https://hub.docker.com/r/caliveapicreator/5.2.00)

### Allgemeine Vorbereitungen 
Um diesen Use Case durchzuführen, benötigen wir natürlich eine Installation von Docker.
Hierzu wird die Variante [**Docker CE**] (https://docs.docker.com/install/) für das zur Verfügung stehende Betriebssystem installiert. 
Sollte die Installation auf der zur Verfügung stehenden Maschine so nicht möglich sein, gibt es natürlich auch immer die Möglichkeit in einer Virtualisierungsumgebung z.B: VMWare Workstation oder [VirtualBox] (https://www.virtualbox.org/) zu arbeiten.

### Herunterladen der benötigten Docker Images
In den oben angegebenen Beschreibungen für unsere drei Docker-Images sind jeweils die notwendigen Befehle angegeben, um diese Images aus dem Docker-Repository in unsere lokale Docker-Umgebung herunterzuladen. Also führen wir die drei, zur Zeit der Erstellung dieses Dokumentes gültigen, folgenden Befehle aus:
(Anmerkung: das $-Zeichen steht nur als Synonym für die Eingabeaufforderung an erster Stelle. Dieses wird **NICHT** mit eingegeben!)

```
$ docker pull mysql
$ docker pull phpmyadmin/phpmyadmin
$ docker pull caliveapicreator/5.2.00
```
Mit dem Befehl ```docker image ls``` werden die vorhandenen Images angezeigt. Details von Docker Komponenten werden mit **docker inspect ....** angezeigt.
Beispiel zum Ausprobieren:

```
$ docker inspect mysql
```

### Vorbereitungen für die Datenbank
Um die Datenbank persistent vorzuhalten, nutze ich in diesem Beispiel ein Docker Volume, welches dann an die richtige Stelle im MySql Docker-Image eingebunden wird.

```
$ docker volume create mysqldb
$ docker volume ls
	DRIVER              VOLUME NAME
	local               mysqldb
$ docker inspect mysqldb
```
Ein Docker-Volume wird dann beim Start über den Parameter **--mount 'src=\<Volume-Name\>,dst=\<Container-Path\>'** eingebunden.

### Start der Datenbank

Nachdem das Volume verfügbar ist, kann die Datenbank gestartet werden. Dieses wird über den Befehl **docker run ....** erledigt.
Damit wird das zu benennende Image zu einem laufenden Container. Das Image bleibt in seiner Gesamtheit unberührt so stehen. Alle zur Laufzeit des Containers stattfindenden Veränderungen finden in dem Container bzw. den gemounteten Dateisystemen/Volumes statt.

Wir starten die Datenbank mit folgendem [**docker run**] (https://docs.docker.com/v17.09/edge/engine/reference/run/) Befehl:

```
$ docker run --name my-mysql -e MYSQL_ROOT_PASSWORD=mysqlfun -d \
  --mount 'src=mysqldb,dst=/var/lib/mysql' \
  mysql:latest
  
```
Erklärungen der Parameter:

| Parameter | Erklärung | Detailinfo |
|:---------|:---------|:----|
|--name    |gibt dem Container einen von uns gewählten Namen|my-mysql|
|-e|setzt eine Umgebungsvariable|Variable: MYSQL\_ROOT\_PASSWORD, Wert: mysqlfun|
|-d| startet den Container im Hintergrund||
|--mount|verbindet den Container mit dem Volume|Volume: mysqldb, Verzeichnis: /var/lib/mysql|
|mysql:latest|Name des zu startenden Docker-Image||

Mit den Befehlen:

```
$ docker ps
$ docker inspect my-mysql
``` 

sehen wir Informationen zu dem laufenden Container.

### Vorbereitungen für PhpMyAdmin und weitere Details

Mit MySql Version 8 wurde der Default-Authentifizierungsmechanismus geändert. Zum Zeitpunkt der Dokumentenerstellung war PhpMyAdmin damit noch nicht kompatibel.
Aus diesem Grunde muss für den Benutzer Root zur Nutzung mit PhpMyAdmin der Default für die Authentifizierung geändert werden.
(Anmerkung: Eine Alternative wäre das Anlegen eines neuen Benutzers mit allen Rechten und dem richtigen Authentifizierungsmechanismus.)
Wir verändern jetzt Dateien im laufenden my-mysql Container und lernen dabei ein wenig.

Um interaktiven Zugriff auf den laufenden Container zu erhalten, führen wir folgenden Befehl aus und starten damit eine interaktive Shell. Details zu [**docker exec**] (https://docs.docker.com/v17.09/edge/engine/reference/commandline/exec/)

```
$ docker exec -it my-mysql bash
```
Im Verzeichnis /etc/mysql findet sich die Datei my.cnf, welche es zu verändern gilt.
Wir wechseln in das Verzeichnis /etc/mysql, anschliessend schreiben wir eine weitere Zeile in die Datei my.cnf und verändern die Authentifizierung für den Benutzer root. Zum Schluss verlassen wir die interaktive Session.

```
/# cd /etc/mysql
/etc/mysql# echo "default_authentication_plugin=mysql_native_password" >>my.cnf
/etc/mysql#  mysql -u root -pmysqlfun -e "ALTER USER root IDENTIFIED WITH mysql_native_password BY 'mysqlfun';"
/etc/mysql# exit
```
Um diese Änderung zu aktivieren muss der laufende Datenbank-Container einmal gestoppt und dann wieder gestartet werden.
(Anmerkung: in den untenstehenden Zeilen ist alles, was hinter dem # steht ein reiner Kommentar. Dieses muss nicht mit angegeben werden.)

```
$ docker stop my-mysql
$ docker ps # Beobachtung?
$ docker ps -a  # Beobachtung? => Richtig, gestoppte Container sieht man nur mit dem Parameter -a
$ docker start my-mysql
$ docker ps # Beobachtung?
```

### Start von PhpMyAdmin
Wie beim Start der Datenbank nutzen wir wieder **docker run** um das Image zu phpmyadmin als Container zu starten:

```
$ docker image ls
$ docker run --name myadmin -d --link my-mysql:db -p 8081:80 phpmyadmin/phpmyadmin
$ docker ps
$ docker inspect myadmin
```

Erklärungen der Parameter:

| Parameter | Erklärung | Detailinfo |
|:---------|:---------|:----|
|--name    |gibt dem Container einen von uns gewählten Namen|myadmin|
|--link|verbindet diesen Container mit dem Datenbank-Container|my-mysql:db|
|-d| startet den Container im Hintergrund||
|-p|verbindet den internen Port x mit dem Host-Port y|interner Port: 80, externer Port: 8081|
|phpmyadmin/phpmyadmin|Name des zu startenden Docker-Image||

#### Erstellen einer persönlichen Datenbank
Um eine persönliche Datenbank zu erstellen, rufen wir [PhpMyAdmin] (http://localhost:8081) auf.
Wir loggen uns mit dem Benutzer **root** und dem gewählten Passwort **mysqlfun** an.

Im PhpMyAdmin legen wir dann einen neuen Benutzer an, vergeben ein Passwort, erstellen eine Datenbank mit dem gleichen Namen und geben dem Benutzer auf diese Datenbank alle Rechte (aber **keine** globalen Rechte!).

![Benutzerkonto hinzufügen] (phpmyadmin_benutzer.png)

Anschliessend erzeugen wir in der frisch erstellten Datenbank eine neue Tabelle mit den von uns gewünschten Spalten.

![Datenbankspalten hinzufügen] (phpmyadmin_spalten.png)

Dieses ist mit wenigen Aktionen in der Oberfläche von PhpMyAdmin erledigt. 

Die neue Tabelle füllen wir dann mit einigen wenigen Datensätzen, damit wir im Layer7 Live Api Creator direkt Ergebnisse sehen.

### Start des Layer7 Live API Creators

Zum Schluss starten wir noch den Live Api Creator, um aus unserer selbst erstellten Datenbank ein Restful API zu generieren. 
Mit diesem API werden wir dann Daten abrufen, ergänzen, ändern und löschen.

```
$ docker run -p 8080:8080 -d --link=my-mysql:db --name liveapicreator caliveapicreator/5.2.00
$ docker ps
$ docker inspect liveapicreator
```

Die für **docker run** genutzten Paramter sind jetzt bekannt bzw. können weiter oben noch einmal nachgelesen werden.

### Nutzen des Layer7 Live API Creators
Wir rufen den [Live API Creator] (http://localhost:8080/APICreator/#/) auf und loggen uns mit dem Benutzer **admin** und dem Passwort **Password1** ein.

Wir erzeugen ein neues API ..

![Neues API hinzufügen] (Create_new_API.png)

aus einer Datenbank ..

![Database first] (Databse_First.png)

dann wählen wir den Datenbanktyp ..

![Database Type] (Select_DB_Type.png)

 und geben die notwendigen Verbindungsparameter ein:
* Host: my-mysql
* Port: 3306
* Username: wie in PhpMyAdmin angegeben
* Passwort: wie in PhpMyAdmin angegeben 

![API Verbindung] (API_Connection.png)

Mit **Test Connection** können die Verbindungsdaten verifiziert werden und anschliessen wird das API mit **Continue** erstellt.

Über den Menupunkt **REST Lab** oder mittels Kommandos wie **curl** bzw. **wget** oder anderen Mitteln kann dann das API genutzt werden.

![REST Lab] (Layer7APICreator/Rest_Lab.png)




