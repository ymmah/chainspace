ps:
	ps aux | grep -v grep | grep chainspace | awk '{print $$2 " " $$11 " " $$12 " " $$13}'

check-port:
	lsof -i :$(port)

list-nodes:
	screen -list

build-jar:
	cd chainspacecore && mvn -q -Dversion=1.0-SNAPSHOT -DskipTests=true package assembly:single

dist: build-jar
	./contrib/package/build-dist.sh

build-docker: dist
	docker build -t decodeproject/chainspace-java:SNAPSHOT .

bash-docker:
	docker run -t -i decodeproject/chainspace-java:SNAPSHOT /bin/bash

push-docker:
	docker push decodeproject/chainspace-java:SNAPSHOT

test:
	./contrib/deploy/test.sh

path=/
curl-client-api:
	curl -v -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:5000/api/1.0$(path) && echo "\n\n"

kill-all:
	ps aux | grep -v grep | grep chainspace | awk '{print $$2}' | xargs kill -12

test-dist: dist
	cd ./target/dist && ./node-config.sh generate ../../contrib/example-networks/localhost-one-shard-two-replicas/localhost-one-shard-two-replicas ../chainspace-nodes .chainspace.env
	pwd
	cp ./contrib/example-networks/localhost-one-shard-two-replicas/start-all.sh ./target/chainspace-nodes/
	cd ./target/chainspace-nodes && tree

clean-dist-db:
	rm -f target/chainspace-nodes/node_0_0/database.sqlite
	rm -f target/chainspace-nodes/node_0_1/database.sqlite

start-dist: clean-dist-db
	cd target/chainspace-nodes && ./start-all.sh


system-test:
	source .chainspace.env/bin/activate && python chainspacecontract/chainspacecontract/system-test/test_increment.py
	source .chainspace.env/bin/activate && python chainspacecontract/chainspacecontract/system-test/test_petition_encrypted.py
