#!/bin/bash
echo -- Caution -- This script should be run with higher privileges
echo Logstash server installer launched.
echo Downloading logstash jar file. It may take a while.
LOGSTASH_DIR=/opt/logstash/
PROJECT_DIR=/opt/logmgmt/
if [ ! -d "$LOGSTASH_DIR" ]; then
  mkdir -p $LOGSTASH_DIR
fi 
cd $LOGSTASH_DIR
wget https://download.elasticsearch.org/logstash/logstash/logstash-1.2.2-flatjar.jar
cd /opt/

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

if [ ! -d "$PROJECT_DIR" ]; then 
  git clone https://github.com/aszulinski/logmgmt.git
fi

# launching logstash server, you may comment this line if you want only install logstash
java -jar /opt/logstash/logstash-1.2.2-flatjar.jar agent -f /opt/logmgmt/configs/logstash.conf -- web
