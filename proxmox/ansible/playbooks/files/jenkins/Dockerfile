# Base Jenkins LTS image
FROM jenkins/jenkins:2.541.1-lts

# Switch to root for installation
USER root

# Install OS dependencies if needed (optional)
# RUN apt-get update && apt-get install -y sudo curl git docker.io kubectl

# Copy plugins list and install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Create Directory
RUN mkdir -p /var/jenkins_home/casc \
    && chown -R jenkins:jenkins /var/jenkins_home

# Copy initial JCasC config 
COPY jenkins.yml /var/jenkins_home/casc/jenkins.yaml

# Switch back to Jenkins user
USER jenkins

# Expose Jenkins default port
EXPOSE 8080