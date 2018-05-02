make kill-all

rm -r .chainspace.env
virtualenv -p $(which python2.7) .chainspace.env
source .chainspace.env/bin/activate

pip install -e chainspacecontract 
pip install -e chainspaceapi
pip install petlib

cd chainspacecore
mvn test
