FROM alpine
MAINTAINER atze.devries@naturalis.nl

ENV BRANCH="" URL=""

RUN apk --no-cache add git openssh

ADD prepare-git.sh /prepare-git.sh
ADD git-update.sh /git-update.sh
ADD wrapper.sh /usr/bin/update-check

CMD update-check $URL $BRANCH
#CMD sh /wrapper.sh $URL $BRANCH
