FROM ncidockerhub.nci.nih.gov/cbiit/centos7_base
MAINTAINER CBIIT App Hosting Engineering Team
# note: requires internet access to github.com, jenkins-ci.org, et al.
# Expected source directory structure:
# <base>/
# |- docker-compose.yml (optional)
# |- jenkins-master/
#    |- bin/
#       |- download-plugins.sh (required)
#       |- jenkins.sh (required)
#       |- plugins.txt (optional)
#    |- Dockerfile (required)
#    |- init.groovy.d/ (required)

# define args
# IMPORTANT: uid & gid must map to valid account in host system
ARG user=jenkinsa
ARG uid=1996
ARG gid=1996
ARG jenkins_port=8080
ARG jenkins_udp=33848
ARG jenkins_jnlp=50000
ARG jenkins_version=2.32.3
ARG jenkins_sha=a25b9a314ca9e76f9673da7309e1882e32674223
ARG jenkins_url=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/$jenkins_version/jenkins-war-$jenkins_version.war
ARG tini_version=0.9.0
ARG tini_sha=fa23d1e20732501c3bb8eeeca423c89ac80ed452
ARG tini_url=https://github.com/krallin/tini/releases/download/v${tini_version}/tini-static
ARG java_io_tmpdir=/local/tmp
ARG user_root=/local/home
ARG repos_host=nciws-d870-v.nci.nih.gov
ARG repos_enabled=1
ARG jenkins_uc=https://updates.jenkins.io
ARG debug

# validate args are set (see https://github.com/docker/compose/issues/3608 for explanation on when args might not be set)
RUN for arg in user uid gid jenkins_port jenkins_udp jenkins_jnlp jenkins_version jenkins_sha jenkins_url tini_version \
  tini_sha tini_url java_io_tmpdir user_root repos_host repos_enabled; do \
    if [ -z "${!arg}" ]; then echo "FATAL: ARG '${!arg}' not set"; exit 1; fi \
  done
  
# define env
# note: keep BIN_DIR in sync with ENTRYPOINT
ENV BIN_DIR=/usr/local/bin \
  REF_DIR=/usr/share/ref/jenkins \
  JENKINS_HOME="/local/content/jenkins" \
  JENKINS_JAVA_CMD="/usr/java8/bin/java" \
  JENKINS_PORT="$jenkins_port" \
  JENKINS_ENABLE_ACCESS_LOG="yes" \
  JENKINS_ARGS="--prefix=/jenkins" \
  JENKINS_WEB_ROOT="/var/lib/jenkins/war" \
  JENKINS_JAVA_OPTIONS="-XshowSettings:vm -XshowSettings:properties \
    -XX:MaxMetaspaceSize=512m -Xmx4096m \
    -Djava.io.tmpdir=$java_io_tmpdir \
    -Djava.awt.headless=true \
    -Dcom.sun.jndi.ldap.connect.timout=10000 -Dcom.sun.jndi.ldap.read.timeout=20000 \
    -Djavax.net.ssl.trustStorePassword=changeit \
    -Djenkins.install.runSetupWizard=false \
    -Dhudson.udp=$jenkins_udp \
  " \
  JENKINS_REINSTALL="" \
  JENKINS_JNLP_PORT=$jenkins_jnlp \
  JENKINS_UC=$jenkins_uc \
  DEBUG=
  
ENV JENKINS_WAR="$JENKINS_HOME/lib/jenkins.war"

# install cbiit yum repo
#TODO: why does \n at end of line cause docker error?
RUN echo -e "[cbiitrepo] \
    \nname=cbiitrepo \
    \nbaseurl=https://$repos_host/cbiit-repo7/ \
    \nenabled=$repos_enabled \
    \ngpgcheck=0 \
    \nsslverify=0" > /etc/yum.repos.d/cbiitrepo.repo

#debug
#RUN rm -f /var/lib/rpm/__* && rpm --rebuilddb -v -v   && yum clean all
#RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
#RUN yum --skip-broken --verbose --noplugins repolist all 
#RUN exit 1

# upgrade and install tools
RUN yum -y upgrade \
  && yum -y install \
    net-tools \ 
    rsync \ 
    shadow-utils \
    unzip \
    vi \
    cbiit-jdk1.8 \
    cbiit-git2 \
  && yum -y clean all

# create jenkins user
RUN groupadd -g $gid $user && mkdir -p $user_root && useradd -m -d $user_root/$user -u $uid -g $user -s /bin/bash $user

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL $tini_url -o /bin/tini && echo "$tini_sha  /bin/tini" | sha1sum -c - && chmod +x /bin/tini

# create java tmp directory
RUN mkdir -p $java_io_tmpdir && chmod a+rwxt $java_io_tmpdir 

# copy files to bin directory
RUN if [ ! -d $BIN_DIR ]; then mkdir -p $BIN_DIR; fi
COPY bin/* $BIN_DIR/
RUN chmod +x $BIN_DIR/*.sh

# create reference directory and log directory placeholder
# '$REF_DIR/' contains all reference configuration we want 
# to set on a fresh new installation. Use it to bundle additional plugins 
# or config file with your custom jenkins Docker image.
RUN mkdir -p $REF_DIR/log

# download jenkins war to reference directory
# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum 
# see https://github.com/docker/docker/issues/8331
RUN if [ ! -d $REF_DIR/lib ]; then mkdir $REF_DIR/lib; fi \
  && curl -fsSL $jenkins_url -o $REF_DIR/lib/jenkins.war && echo "$jenkins_sha $REF_DIR/lib/jenkins.war" | sha1sum -c -
#COPY lib/ $REF_DIR/lib/

# download plugins to reference directory
RUN env DEBUG=$debug $BIN_DIR/download-plugins.sh

# copy init groovy scripts to reference directory
RUN mkdir $REF_DIR/init.groovy.d
COPY init.groovy.d $REF_DIR/init.groovy.d

# create jenkins web root directory
RUN mkdir -p $JENKINS_WEB_ROOT && chown -R $user. $JENKINS_WEB_ROOT

# create workspace directories
# Jenkins is run with user $user, uid = $uid.  If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME/log && chown -R $user. $JENKINS_HOME

# ensure appropriate files owned by jenkins user
RUN chown $user. -R $REF_DIR/ $JENKINS_HOME/

# configure ports
EXPOSE $jenkins_port $jenkins_udp/udp $jenkins_jnlp

# switch user
RUN echo "Current user: $user ($uid)"
USER $user

# define entry point
#TODO: why does exec form not accept env var??
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

