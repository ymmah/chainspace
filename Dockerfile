FROM alpine:3.6

ARG zenroom_tag=v0.7.1

WORKDIR /code/zenroom

RUN apk update
RUN apk upgrade
RUN apk add --no-cache git openssh git

RUN git clone \
    --single-branch --branch ${zenroom_tag} \
    https://github.com/DECODEproject/zenroom.git \
    . \
 && git submodule init \
 && git submodule update

RUN apk add --no-cache make cmake gcc musl-dev musl musl-utils
RUN make musl-system

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

COPY --from=0 /code/zenroom/src/zenroom-static /usr/bin/zenroom
COPY --from=0 /code/zenroom/examples/elgamal  /opt/contracts/

RUN easy_install pip
WORKDIR /app
RUN virtualenv .chainspace.env
RUN . .chainspace.env/bin/activate && pip install -U setuptools
RUN . .chainspace.env/bin/activate && pip install -e ./chainspaceapi
RUN . .chainspace.env/bin/activate && pip install -e ./chainspacecontract
RUN . .chainspace.env/bin/activate && pip install petlib
RUN . .chainspace.env/bin/activate && make build-jar

CMD make start-nodes && make start-client-api
