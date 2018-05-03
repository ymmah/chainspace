FROM ubuntu:16.04

RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant screen virtualenv python python-setuptools wget gzip \
                           build-essential libssl-dev libffi-dev python-dev maven && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*;


COPY chainspaceapi /app/chainspaceapi
COPY chainspacecontract /app/chainspacecontract
COPY chainspacecore /app/chainspacecore
COPY contrib /app/contrib
COPY Makefile /app/

RUN easy_install pip
WORKDIR /app
RUN virtualenv .chainspace.env
RUN . .chainspace.env/bin/activate && pip install -U setuptools
RUN . .chainspace.env/bin/activate && pip install -e ./chainspaceapi
RUN . .chainspace.env/bin/activate && pip install -e ./chainspacecontract
RUN . .chainspace.env/bin/activate && pip install petlib
RUN . .chainspace.env/bin/activate && make build-jar

CMD make start-nodes && make start-client-api
