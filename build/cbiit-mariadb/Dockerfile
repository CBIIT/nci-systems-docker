FROM ncidockerhub.nci.nih.gov/cbiit/centos7_base

ENV ARCH amd64


ADD mariadb.repo /etc/yum.repos.d/
ADD entrypoint.sh /usr/local/bin


RUN yum -y install epel-release \
 && yum -y install vi hostname MariaDB-server bind-utils psmisc wget pwgen \
 && yum clean all

RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$ARCH" \
 && chmod +x /usr/local/bin/gosu \
 && echo -e "[mysqld]\nskip-host-cache\nskip-name-resolve\nignore-db-dir=lost+found" > /etc/my.cnf.d/docker.cnf \
 
 # purge and re-create /var/lib/mysql with appropriate ownership
 && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
 && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
 #ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
 && chmod 777 /var/run/mysqld

 
EXPOSE 3306

VOLUME /var/lib/mysql

ENTRYPOINT ["entrypoint.sh"]

CMD ["mysqld"]

