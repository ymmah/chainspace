FROM dyne/zenroom:0.8.1
FROM ubuntu:16.04

RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y virtualenv tree python python-setuptools wget gzip vim emacs \
                           build-essential libssl-dev libffi-dev python-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*;

RUN easy_install pip


COPY --from=0 /code/zenroom/src/zenroom-static /usr/bin/zenroom
COPY --from=0 /code/zenroom/examples/elgamal  /opt/contracts/

WORKDIR /app
COPY target/chainspace-bin-vSNAPSHOT.tgz .

RUN pwd && ls

WORKDIR /app/chainspace

RUN tar xfz /app/chainspace-bin-vSNAPSHOT.tgz

RUN ls

RUN ./node-config.sh generate ./example-networks/localhost-one-shard-two-replicas ../chainspace-nodes .chainspace.env


WORKDIR /app/chainspace-nodes

RUN virtualenv .chainspace.env
RUN . .chainspace.env/bin/activate && pip install -U setuptools
RUN . .chainspace.env/bin/activate && pip install -e ../chainspace/lib/chainspaceapi
RUN . .chainspace.env/bin/activate && pip install -e ../chainspace/lib/chainspacecontract
RUN . .chainspace.env/bin/activate && pip install petlib numpy bplib coconut-lib

WORKDIR /app/chainspace
CMD ./start-all.sh
