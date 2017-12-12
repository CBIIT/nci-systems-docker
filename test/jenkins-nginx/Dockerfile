FROM cbiit/centos7:base

RUN yum -y update;yum clean all
#RUN yum -y install openssh openssh-server openssh-client epel-release 
#RUN yum -y install --enablerepo=epel nginx
RUN yum -y install nginx
RUN systemctl enable sshd.service nginx.service
COPY conf/jenkins.conf /etc/nginx/conf.d/jenkins.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx"]
