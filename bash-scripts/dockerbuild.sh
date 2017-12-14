#title           :dockerbuild.sh
#description     :This script builds docker images on regular basis based on crond definition.
#author		 	 :NCI CBIIT Apphosting Team
#date            :2017-10-30
#version         :0.1.0   
#usage		     :sh dockerbuild.sh  Note this script assumes the values of DOCKER_USER and DOCKER_USER_PW are env variables( export DOCKER_USER=user, export DOCKER_USER_PW=password)


SVNURL=https://github.com/CBIIT/nci-systems-docker-pub/trunk/$Location/$Image

WORKDIR=${WORKSPACE}/docker-autobuild
DOCKERFILE_BASE=$WORKDIR/$Location

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

#echo "Development user $DOCKER_DEV_USER"
#echo "Production user $DOCKER_PROD_USER"
#Login to ncidockerhub.nci.nih.gov
if [ "$Location" = "cbiit-dev" ]; then
  echo "login to ncidockerhub with $DOCKER_DEV_USER"
  docker login ncidockerhub.nci.nih.gov --username $DOCKER_DEV_USER --password $DOCKER_USER_PW
fi

if [ "$Location" = "cbiit" ]; then
  echo "login to ncidockerhub with $DOCKER_PROD_USER"
  docker login ncidockerhub.nci.nih.gov --username $DOCKER_PROD_USER --password $DOCKER_USER_PW
fi


#set name for the images

name=$Location

#if [[ $Location == "build" ]];
#		then
#		name="cbiit"
#fi


#Build each image and push them to ncidockerhub. 

pushd $Image
docker build -t ncidockerhub.nci.nih.gov/$name/$Image --no-cache .
docker push ncidockerhub.nci.nih.gov/$name/$Image
popd
    
#Delete all built images
#docker rmi $(docker images -q) -f

