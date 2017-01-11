#!/bin/bash

sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $(hostname)/g" /etc/hosts

apt-key adv \
    --keyserver hkp://ha.pool.sks-keyservers.net:80 \
    --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list

apt-get update

apt-get install -y docker-engine

/sbin/sysctl -w vm.max_map_count=262144

mkdir /nba-data
mkdir /es-data
mkdir /es-snapshots
chmod 777 es-snapshots

wget -O /etc/screenrc     http://git.grml.org/f/grml-etc-core/etc/grml/screenrc_generic

usermod -aG docker ubuntu

docker run -d --name my-es-01 \
   -e ES_JAVA_OPTS="-Xms4g -Xmx4g" \
   -v /es-data:/usr/share/elasticsearch/data \
   -v /es-snapshots:/es-snapshots \
   elasticsearch:2.3.5 elasticsearch \
     -Des.cluster.name="nba-cluster" \
     -Des.index.number_of_replicas=0 \
     -Des.path.repo="/es-snapshots"

docker run -d --name my-nba-api \
  -p 8080:8080 \
  --link my-es-01:es \
  atzedevries/nba-wildfly-v2_master

docker run -d --name my-nba-etl \
  -v /nba-data:/payload/data \
  --link my-es-01:es \
  atzedevries/nba-etl-v2_master

docker run -d --name my-kibana \
  -e ELASTICSEARCH_URL=http://es:9200 \
  -p 5601:5601 \
  --link my-es-01:es \
  atzedevries/kibana-sense:4.5

docker pull clue/httpie
docker pull appropriate/curl

echo alias curl='"docker run -it --rm --link my-es-01:es appropriate/curl"' >> /root/.bashrc
echo alias http='"docker run -it --rm --link my-es-01:es clue/httpie"' >> /root/.bashrc

echo alias curl='"docker run -it --rm --link my-es-01:es appropriate/curl"' >> /home/ubuntu/.bashrc
echo alias http='"docker run -it --rm --link my-es-01:es clue/httpie"' >> /home/ubuntu/.bashrc
docker run --rm --link my-es-01:es appropriate/curl -XPOST es:9200/_snapshot/mybackup -d '{"type":"fs", "settings":{"location":"/es-snapshots","compress":true}}'
