# Elastic 
Da unsere automation.ai Plattform auf Elastic Search basiert, wollte ich zumindest einmal die Basics in einem ersten Schritt ausprobieren.

Die Basics von Docker sollten im Rahmen der vorherigen Kapitel klar sein. Darauf gehe ich hier jetzt nicht mehr ein.

## Installation und Startup
Achtung: Bei diesen Schritten gibt es noch keine Persistence! 

```
docker pull elasticsearch:7.4.2
docker pull kibana:7.4.2
docker network create elastic
docker run -d --name elasticsearch --net elastic -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.4.2
docker run -d --name kibana --net elastic -p 5601:5601 kibana:7.4.2
```

Danach kann auf **Elastic** über Browser/SoapUI/Postman etc. mit **http://localhost:9200** zugegriffen werden.

Der ersten Einstieg findet am besten direkt über **Kibana** mittels **http://localhost:5601/** statt. Kibana ermöglicht Beispieldatensätze/Visualisierungen/Dashboards zu laden. 

## Weiterführende Literatur
* [Einführung Elasticsearch mit Kibana](https://medium.com/@victorsmelopoa/an-introduction-to-elasticsearch-with-kibana-78071db3704)
* [Tutorial Visualisierung](https://www.elastic.co/guide/en/kibana/current/tutorial-visualizing.html)
* [Beispiel Abfragen](https://dzone.com/articles/23-useful-elasticsearch-example-queries)

Beachtet bitte, dass bei einigen Beispielen der Hinweis auf den HTTP Header "content-type:application/json" fehlt und daher Fehlermeldungen bei http get/post/.. aufkommen.




