FROM dyne/zenroom:0.8.1
FROM ubuntu:16.04

RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y virtualenv tree python python-setuptools wget gzip \
                           build-essential libssl-dev libffi-dev python-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*;

COPY --from=0 /code/zenroom/src/zenroom-static /usr/bin/zenroom
COPY --from=0 /code/zenroom/examples/elgamal  /opt/contracts/

RUN easy_install pip

WORKDIR /app

RUN virtualenv .chainspace.env
RUN . .chainspace.env/bin/activate && pip install -U setuptools
RUN . .chainspace.env/bin/activate && pip install petlib numpy bplib coconut-lib


COPY target/chainspace-bin-vSNAPSHOT.tgz /app/

WORKDIR /app/chainspace

RUN tar xfz /app/chainspace-bin-vSNAPSHOT.tgz

WORKDIR /app

RUN . .chainspace.env/bin/activate && pip install -e chainspace/lib/chainspaceapi
RUN . .chainspace.env/bin/activate && pip install -e chainspace/lib/chainspacecontract





