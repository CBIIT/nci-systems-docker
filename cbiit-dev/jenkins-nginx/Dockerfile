FROM cbiit/centos7_base
MAINTAINER CBIIT App hosting Engineering team

#Some yum updates and required package install
RUN yum -y update
RUN yum -y install openssh openssh-server openssh-client epel-release

#Install nginx and enable service 
RUN yum -y install --enablerepo=epel nginx
RUN systemctl enable sshd.service nginx.service

#Configure nginx for Jenkins
COPY conf/jenkins.conf /etc/nginx/conf.d/jenkins.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf

#Allowing port 80
EXPOSE 80
CMD ["nginx"]
