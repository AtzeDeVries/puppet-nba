FROM openjdk:8-alpine
MAINTAINER atze.devries@naturalis.nl
RUN mkdir /payload
RUN apk add --no-cache bash
WORKDIR /payload
ADD software software
RUN mkdir data
CMD /bin/bash -c 'while true; do echo this is the etl module ; sleep 600 ; done'
