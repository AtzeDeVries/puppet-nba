Deployment for test systems
-----------------------------

Use the deployment script for openstack which van be found here
https://raw.githubusercontent.com/AtzeDeVries/puppet-nba/master/openstack_bootstrap.sh


### Interact with elasticsearch from CLI
```
curl -XGET es:9200/_cat/health
```

### Interact with elasticsearch via Kibana-sense
Use http://es:9200  instead of http:9200/localhost

### Using snapshots
By default a snaphot repository called *mybackup* is injected. Snapshot data is stored on
the hostsystem in /es-snapshot
If you want to import snapshot data copy it to /es-snapshot

### Update API
```
docker pull atzedevries/nba-wildfly-v2_master
```
Check command if image is updated. If so stop the current image
```
docker rm -f my-nba-api
```
Then start a new one
```
docker run -d --name my-nba-api -p 8080:8080 --link my-es-01:es atzedevries/nba-wildfly-v2_master
```

### Update the ETL
```
docker pull atzedevries/nba-etl-v2_master
```
Check command if image is updated. If so stop the current image
```
docker rm -f my-nba-etl
```
Then start a new one
```
docker run -d --name my-nba-etl \
  -v /nba-data:/payload/data \
  --link my-es-01:es \
  atzedevries/nba-etl-v2_master
```

### Run two versions of the api against the same ES
* Visit https://hub.docker.com/r/atzedevries/nba-wildfly-v2_master/tags/
* Choose the tag you want

For example we use as tag: 2017.01.10-13.29

By default nba api is reachable on port 8080. You can't allocate this twice so define
different version of the api on port 8081 (or 8082 etc)
```
docker run -d --name my-nba-api-other-version -p 8081:8080 --link my-es-01:es atzedevries/nba-wildfly-v2_master:2017.01.10-13.29
```
