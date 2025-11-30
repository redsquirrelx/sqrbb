FROM jenkins/jenkins:2.538-jdk21

USER root

# Docker CLI
RUN apt-get update
RUN apt-get install ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

RUN <<TOR
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
TOR

RUN apt-get update
RUN apt-get install -y docker-ce-cli=5:28.4.0-1~debian.13~trixie

# Utilidades

# less
RUN apt-get install less

# vim
RUN apt-get install -y vim

# TERRAFORM
RUN apt-get update
RUN apt-get install wget
RUN wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

RUN CODENAME=$( . /etc/os-release && echo $VERSION_CODENAME ) \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${CODENAME} main" \
        > /etc/apt/sources.list.d/hashicorp.list

# Plugins
COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins/install-plugins.sh /usr/local/bin/install-plugins.sh

RUN chmod +x /usr/local/bin/install-plugins.sh
RUN /usr/local/bin/install-plugins.sh /usr/share/jenkins/ref/plugins.txt

EXPOSE 8080 50000