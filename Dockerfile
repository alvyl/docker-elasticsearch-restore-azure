FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y -q && \
  apt-get install -y nodejs curl wget npm cron jq && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /restore
ADD . /restore
RUN chmod 0755 /restore/*

VOLUME /usr/share/elasticsearch/restore

ENTRYPOINT ["/restore/caller.sh"]
