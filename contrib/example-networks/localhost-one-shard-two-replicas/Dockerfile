FROM decodeproject/chainspace-java:SNAPSHOT

WORKDIR /app/chainspace-network-conf

COPY ./localhost-one-shard-two-replicas.sh .

RUN ls -lart

WORKDIR /app/chainspace

RUN ./node-config.sh generate ../chainspace-network-conf/localhost-one-shard-two-replicas ../chainspace-nodes .chainspace.env

WORKDIR /app/chainspace-nodes

COPY start-all.sh .

CMD ./start-all.sh

