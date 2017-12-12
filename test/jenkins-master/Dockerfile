FROM cbiit/centos7:base
MAINTAINER CBIIT App Hosting Engineering Team

#Install some required packages via yum
#RUN yum -y update && yum -y install git unzip
RUN yum -y install git unzip

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
#ARG port=8080
#ARG jenk_version=2.19.2
ARG jenk_version=2.32.2

ENV JENKINS_HOME /local/content/jenkins

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid

RUN mkdir -p /local/content/jenkins
RUN useradd -d “/local/content/jenkins” -u 1000 -m -s /bin/bash jenkins
#RUN groupadd -g ${gid} ${group} \
#    && useradd --home-dir "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
RUN usermod -m -d $JENKINS_HOME ${user}

#COPY conf/cbiit-jdk1.8-131-1.el7.x86_64.rpm $JENKINS_HOME
RUN curl -LOk https://nciws-d709-v.nci.nih.gov/cbiit-repo7/prior-versions/cbiit-jdk1.8-131-1.el7.x86_64.rpm > $JENKINS_HOME/cbiit-jdk1.8-131-1.el7.x86_64.rpm
RUN rpm -Uvh $JENKINS_HOME/cbiit-jdk1.8-131-1.el7.x86_64.rpm

# `/usr/share/jenkins/ref/` contains all reference configuration we want 
# to set on a fresh new installation. Use it to bundle additional plugins 
# or config file with your custom jenkins Docker image.
RUN mkdir -p /local/content/jenkins/log
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
RUN mkdir -p /usr/share/jenkins/ref/plugins

ENV TINI_VERSION 0.9.0
ENV TINI_SHA fa23d1e20732501c3bb8eeeca423c89ac80ed452

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha1sum -c -

COPY conf/init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
#COPY conf/default-admin.groovy /usr/share/jenkins/ref/init.groovy.d/default-admin.groovy

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-${jenk_version}}
ENV PATH="/usr/local/jdk1.8/bin:${PATH}"

# jenkins.war checksum, download will be validated using it
#ARG JENKINS_SHA=32b8bd1a86d6d4a91889bd38fb665db4090db081
#Version 2.32.2
ARG JENKINS_SHA=f495a08733f69b1845fd2d9b3a46482adb6e6cee
#ARG JENKINS_SHA

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum 
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha1sum -c -

ENV JENKINS_UC https://updates.jenkins.io

RUN chown -R ${user}:${group} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
USER ${user}

#ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JAVA_OPTS="-Xmx4096m"
#ENV JENKINS_OPTS="--prefix=/jenkins"

COPY conf/jenkins-support /usr/local/bin/jenkins-support
COPY conf/jenkins.sh /usr/local/bin/jenkins.sh

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
RUN mkdir -p /usr/share/jenkins/ref/plugins/
COPY conf/dec5-plugins.txt /usr/share/jenkins/plugins.txt
COPY conf/install-plugins.sh /usr/local/bin/install-plugins.sh
USER root
RUN chown -R ${user}:${group} "$JENKINS_HOME"
RUN /usr/local/bin/install-plugins.sh /usr/share/jenkins/plugins.txt

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

# Config settings for AD, ant, maven, git and mailer
COPY conf/hudson.tasks.Mailer.xml $JENKINS_HOME
COPY conf/hudson.tasks.Ant.xml $JENKINS_HOME
COPY conf/hudson.tasks.Maven.xml $JENKINS_HOME
COPY conf/hudson.plugins.git.GitTool.xml $JENKINS_HOME
COPY conf/config.xml $JENKINS_HOME
#COPY conf/admin_config.xml $JENKINS_HOME/users/admin/config.xml

# fix permissions
USER root
RUN chown -R ${user}:${group} "$JENKINS_HOME" 

# drop back to jenkins user
USER ${user}

# Prefix of the URL path
ENV JENKINS_OPTS="--prefix=/jenkins"

# disable initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
