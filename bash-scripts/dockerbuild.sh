#!/bin/bash

#title           :dockerbuild.sh
#description     :This script builds docker images on regular basis based on crond definition.
#author		 	 :NCI CBIIT Apphosting Team
#date            :2017-10-30
#version         :0.1.0   
#usage		     :sh dockerbuild.sh  Note this script assumes the values of DOCKER_USER and DOCKER_USER_PW are env variables( export DOCKER_USER=user, export DOCKER_USER_PW=password)


SVNURL=https://github.com/CBIIT/nci-systems-docker-pub/trunk/build
WORKDIR=~/docker-autobuild
DOCKERFILE_BASE=$WORKDIR/build

#Ensure the workdir exist if not
if [[ ! -d $WORKDIR ]];
 	then
 	mkdir $WORKDIR
fi

#Remove the old build directory if any
if [[  -d $DOCKERFILE_BASE ]];
 	then
 	rm -rf  $DOCKERFILE_BASE
fi

 #Checkout nci docker files from github
 cd $WORKDIR
 svn checkout $SVNURL

#Login to ncidockerhub.nci.nih.gov
docker login ncidockerhub.nci.nih.gov --username $DOCKER_USER --password $DOCKER_USER_PW

#List all the docker images directory in the build folder
IMAGES=`find build -type d -maxdepth 1 | cut -d'/' -f2  | grep -v 'build$' | grep -v '\.svn$'`

#Build each image and push them to ncidockerhub. 
for image in $IMAGES
do
	pushd build/$image
	docker build -t ncidockerhub.nci.nih.gov/cbiit/cbiit-$image --no-cache .
	docker push ncidockerhub.nci.nih.gov/cbiit/cbiit-$image
	popd
done

