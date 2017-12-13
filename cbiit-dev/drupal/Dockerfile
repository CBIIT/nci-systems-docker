FROM ncidockerhub.nci.nih.gov/cbiit/centos7_base:latest
 
#Drupal version to be installed
ARG DRUPAL_VERSION=7.56 

#Add configure internal cbiit repos
ADD ./cbiit.repo /etc/yum.repos.d 

#Install all the necessary packages for drupal
RUN yum -y install yum-plugin-ovl \
&& yum -y upgrade \
&& yum -y install which \
&& yum -y install wget \
&& yum -y install epel-release \
&& yum -y install cbiit-apache2.4 \
&& yum -y install cbiit-php5.6 \
&& yum -y install mysql \
&& yum -y install drush \
&& yum -y install libtool-ltdl\
&& yum -y install php-mysql\
&& yum -y install vi \
&& yum clean all
 

RUN groupadd drupal -g 26013 \
&& useradd drupal -g drupal -u 26013  \
&& usermod -aG apache drupal \
&& mkdir -p /local/drupal/cbiitdrupal \
&& chmod -R 755 /local/drupal \
&& cd /tmp \
&& wget https://ftp.drupal.org/files/projects/drupal-$DRUPAL_VERSION.tar.gz \
&& tar xz --strip-components=1 -f drupal-$DRUPAL_VERSION.tar.gz  -C /local/drupal/cbiitdrupal \
&& rm drupal-${DRUPAL_VERSION}.tar.gz \
&& chown -R drupal:drupal /local/drupal

ENTRYPOINT ["/usr/local/apache2.4/bin/httpd","-k", "start", "-DFOREGROUND"]  