#!/bin/bash
docker run -d -p 8082:8080 --name lac52-8082 \
-v /Users/grean11/Docker_Runtime/LiveAPICreator/CALiveAPICreator.repository:/home/tomcat/CALiveAPICreator.repository \
-v /Users/grean11/Docker_Runtime/LiveAPICreator/databases:/usr/local/CALiveAPICreator/databases \
caliveapicreator/5.2.00
