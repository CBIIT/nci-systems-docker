# Needs to match the centos version used in jenkins-master
FROM cbiit/centos7:base
MAINTAINER CBIIT Systems host Engineering team

#Running yum update
RUN yum -y update && yum -y install git unzip

#Goblal variables
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ENV JENKINS_HOME /local/content/jenkins
ENV JENKINS_LOG /local/content/jenkins/log

# user${uid} must match the user id for the jenkins user in jenkins-master
RUN mkdir -p $JENKINS_HOME
RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN mkdir -p $JENKINS_LOG
RUN chown -R ${user}:${group} $JENKINS_LOG

VOLUME ["$JENKINS_LOG", "$JENKINS_HOME"]

USER ${user}

CMD ["echo", "Data container for Jenkins"]

