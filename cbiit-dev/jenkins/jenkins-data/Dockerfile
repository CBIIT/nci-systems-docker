# Needs to match the centos version used in jenkins-master
FROM ncidockerhub.nci.nih.gov/cbiit-dev/jenkins-data:latest
#FROM centos:latest
#USER root
#RUN chown -R jenkins:jenkins /local/content/jenkins/
# Config settings for AD, ant, maven, git and mailer
COPY conf/hudson.tasks.Mailer.xml $JENKINS_HOME
COPY conf/hudson.tasks.Ant.xml $JENKINS_HOME
COPY conf/hudson.tasks.Maven.xml $JENKINS_HOME
COPY conf/hudson.plugins.git.GitTool.xml $JENKINS_HOME
COPY conf/config.xml $JENKINS_HOME
CMD ["echo", "Data container for Jenkins"]

