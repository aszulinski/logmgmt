#!/bin/bash
echo 'Script takes three parameters needed to retrieve certificate from logstash server: USERNAME IP_ADDRESS PATH_TO_CERTIFICATE'
echo '-- Caution -- This script should be run with higher privileges'
echo 'Logstash-forwarder(lumberjack) installer launched.'
echo 'Downloading logstash-forwarder repository files.'
FORWARDER_DIR=/opt/logstash-forwarder
PROJECT_DIR=/opt/logmgmt

$(which git > /dev/null 2>&1)
FOUND_GIT=$?
if [ "$FOUND_GIT" -ne '0' ]; then
  echo 'Attempting to install git.'
  $(which apt-get > /dev/null 2>&1)
  FOUND_APT=$?
  $(which yum > /dev/null 2>&1)
  FOUND_YUM=$?

  if [ "${FOUND_YUM}" -eq '0' ]; then
    yum -q -y makecache
    yum -q -y install git
    echo 'git installed.'
  elif [ "${FOUND_APT}" -eq '0' ]; then
    apt-get -q -y update
    apt-get -q -y install git
    echo 'git installed.'
  else
    echo 'No package installer available. You may need to install git manually.'
  fi
else
  echo 'git found.'
fi

cd /opt/
apt-get install make
apt-get install rubygems
gem install fpm

apt-get remove golang-go
apt-get remove golang-stable

$(which go > /dev/null 2>&1)
FOUND_GO=$?
if [ "$FOUND_GO" -ne '0' ]; then
  echo 'Installing Go language. It may take a while.'
  wget https://go.googlecode.com/files/go1.1.2.linux-amd64.tar.gz
  tar -C /usr/local -xzf go1.1.2.linux-amd64.tar.gz
  export PATH=$PATH:/usr/local/go/bin
else
  export PATH=$PATH:/usr/local/go/bin
fi

echo 'Logstash-forwarder building and running.'
if [ ! -d "$FORWARDER_DIR" ]; then
  cd /opt/
  git clone git://github.com/elasticsearch/logstash-forwarder.git
fi

cd $FORWARDER_DIR
go build
make deb
dpkg -i lumberjack_0.3.1_amd64.deb

cd /opt/
if [ ! -d "$PROJECT_DIR" ]; then 
  git clone https://github.com/aszulinski/logmgmt.git
fi

scp $1@$2:$3 /etc/ssl/logstash.pub
sed -i.bak "s/\".*servers.*/\"servers\":[\"$2:4545\"],/" $PROJECT_DIR/configs/forwarder.conf

cp $PROJECT_DIR/configs/forwarder.conf /etc/logstash-forwarder
update-rc.d logstash-forwarder defaults

# launching logstash-forwarder via service
# service logstash-forwarder start
