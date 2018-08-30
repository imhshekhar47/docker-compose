FROM docker.elastic.co/logstash/logstash:6.4.0
COPY --chown=logstash:logstash lib /lib
COPY --chown=logstash:logstash config /usr/share/logstash/config
COPY --chown=logstash:logstash pipeline /usr/share/logstash/pipeline
COPY --chown=logstash:logstash scripts /scripts
RUN rm /usr/share/logstash/pipeline/logstash.conf