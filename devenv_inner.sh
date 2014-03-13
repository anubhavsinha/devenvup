#!/bin/bash
set -ex

DIR="$( cd "$( dirname "$0" )" && pwd )"
APPS=${APPS:-/mnt/apps}

#echo $DIR
#echo $APPS

killz(){
	echo "Killing all docker containers:"
	docker kill $(docker ps -a -q)
	docker rm $(docker ps -a -q)
	}

stop(){
	echo "Stopping all docker containers:"
	docker stop $(docker ps -a -q)
	docker rm $(docker ps -a -q)
	}

start(){
	docker run -v /home/vagrant/cassandra:/var/lib/cassandra -d -p 9160:9160 -name db flux7/cassandra
	# need to map port 80 in vagrant file	
	python power-monitoring/providers.py
	
	}

setup(){
	echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
	apt-get -y update
	apt-get -y install build-essential
	apt-get update
        apt-get install linux-image-extra-`uname -r`	
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
	apt-get update
	apt-get install lxc-docker
	apt-get -y install git
	apt-get -y install python-setuptools
	easy_install pip
	apt-get -y install python-dev
	apt-get update	
	pip install pycassa	
	pip install flask
	pip install docker-py
	git clone https://anubhavsinha:GNixv10a@github.com/anubhavsinha/power-monitoring.git
	git clone https://anubhavsinha:GNixv10a@github.com/anubhavsinha/cassandra-standalone-dockerfile.git
	mkdir -p /home/vagrant/cassandra
	python power-monitoring/setup_providers_db.py
	docker build -t flux7/power-monitoring power-monitoring/Dockerfile
	docker build -t flux7/cassandra cassandra-standalone-dockerfile/Dockerfile
	}

update(){

	
	}


case "$1" in
		restart)
			killz
			start
			;;
		start)
			start
			;;
		stop)
			stop
			;;
		kill)
			killz
			;;
		update)
			update
			;;
		status)
			docker ps
			;;
		*)
		echo $"Usage: $0 {start|stop|kill|update|restart|status|ssh}"
		RETVAL=1
esac


