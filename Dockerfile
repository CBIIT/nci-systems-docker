FROM cbiit/centos7:base
RUN yum -y update && yum -y install git unzip
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG port=8080

ENV JENKINS_HOME /local/content/jenkins/${port}
ENV JENKINS_SLAVE_AGENT_PORT 50000
#ENV LDAP_HOST ldapad.nih.gov
#ENV LDAP_PORT 636
#ENV LDAP_BASE_DN OU=NCI,OU=NIH,OU=AD,DC=nih,Dc=gov
RUN mkdir -p /local/content/jenkins
RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
COPY /cbiit-jdk1.8-131-1.el7.x86_64.rpm $JENKINS_HOME
RUN rpm -Uvh $JENKINS_HOME/cbiit-jdk1.8-131-1.el7.x86_64.rpm

RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
RUN mkdir -p /usr/share/jenkins/ref/plugins
RUN mkdir -p /var/log/jenkins
RUN mkdir -p /var/cache/jenkins-${port}

ENV TINI_VERSION 0.14.0
ENV TINI_SHA 6c41ec7d33e857d4779f14d9c74924cab0c7973485d2972419a3b7c7620ff5fd

RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.57}
ARG JENKINS_SHA=5d7a66864d0941629e1fb8ef82ed98a38e54da39f4a9f3ca31561d573e18b2a5
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
#COPY config.xml /usr/share/jenkins/ref
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
#COPY admin_config.xml $JENKINS_HOME/users/admin/config.xml

RUN chown -R ${user}:${group} $JENKINS_HOME /var/log/jenkins /usr/share/jenkins/ref /var/cache/jenkins-${port}
EXPOSE 8080

EXPOSE 50000
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
#RUN EXPORT PATH=/usr/local:$PATH
ENV PATH="/usr/local/jdk1.8/bin:${PATH}"
USER ${user}

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
#COPY config.xml $JENKINS_HOME
#COPY admin_config.xml $JENKINS_HOME/users/admin/config.xml

ENV JENKINS_OPTS="--handlerCountMax=100 --handlerCountMaxIdle=20 --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins-${port}/war --prefix=/jenkins"

COPY install-plugins.sh /usr/local/bin/install-plugins.sh
RUN /usr/local/bin/install-plugins.sh audit-trail configurationslicing copyartifact dynamicparameter envinject extended-read-permission git-parameter jobConfigHistory ownership plugin-usage-plugin purge-build-queue-plugin purge-job-history ssh-slaves thread-dump-action-plugin ws-cleanup ace-editor ant antisamy-markup-formatter bouncycastle-api build-timeout cloudbees-folder conditional-buildstep credentials cvs display-url-api email-ext external-monitor-job git git-client git-server icon-shim javadoc job-restrictions jquery jquery-detached junit ldap mailer mask-passwords matrix-auth matrix-project maven-plugin pam-auth parameterized-trigger rebuild resource-disposer role-strategy run-condition scm-api script-security scriptler ssh-credentials structs timestamper token-macro windows-slaves workflow-api workflow-basic-steps workflow-cps workflow-scm-step workflow-step-api workflow-support

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

