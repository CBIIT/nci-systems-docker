FROM ncidockerhub.nci.nih.gov/cbiit/centos7_base

LABEL maintainer="nci"
LABEL version="1.0"
LABEL description="This is simple varnish image using nci rpms"

#Update the base os, enable epel and install varnish including dependencies
RUN yum -y update  && \
  yum -y install epel-release && \
  yum -y install varnish && \
  yum -y install libmhash-devel && \
  yum -y install vi \
  yum clean all

#Copy nci default varnish settings to the image including the entrypoint
ADD default.vcl /etc/varnish/default.vcl
ADD entrypoint.sh /entrypoint.sh
ADD varnish.params /etc/varnish/varnish.params

#Make configuration flexible by setting some environment variables
ENV BACKEND_HOST 127.0.0.1
ENV BACKEND_PORT 8181
ENV CACHE_SIZE  128m 

#Expose varnish port for connection
EXPOSE 6081

CMD [ "/entrypoint.sh" ]

