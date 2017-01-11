NBA and ETL deployment
--------------------------

Deployments are based on docker.

Very simple example.

Run elasticsearch
```
docker run -d --name my-es-01 \
  -e ES_JAVA_OPTS="-Xms2048m -Xmx2048m" \
  elasticsearch:2.3.5 elasticsearch -Des.cluster.name="nba-cluster"
```
Run nba-api (with exposed port 8080)
```
docker run -d --name my-nba-api \
  -p 8080:8080 \
  --link my-es-01:es \
  atzedevries/nba-wildfly-v2_master
```
Run etl-module (asume your data diretory is /nba-data) and run import-all
```
docker run --rm -it --name my-nba-etl \
  -v /nba-data:/payload/data \
  --link my-etl-01:es \
  atzedevries/nba-etl-v2_master
```
This will enter in a interactive mode and you can kickoff a .
```
cd software/sh && bash import-all
```
