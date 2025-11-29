FROM jenkins/jenkins:2.535-jdk21

USER root

# Docker CLI
RUN apt-get update
RUN apt-get install ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

RUN <<EOF
    tee /etc/apt/sources.list.d/docker.sources <<EOF
    Types: deb
    URIs: https://download.docker.com/linux/debian
    Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
    Components: stable
    Signed-By: /etc/apt/keyrings/docker.asc
    EOF
EOF

RUN apt-get update
RUN apt-get install docker-cli=26.1.5+dfsg1-9+b9 docker-buildx=0.13.1+ds1-3

# Ansible
RUN apt-get install wget
RUN <<EOF
    UBUNTU_CODENAME=noble
    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" \
        | gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" \
        | tee /etc/apt/sources.list.d/ansible.list
EOF
RUN apt-get update
RUN apt-get install -y ansible=12.2.0-1ppa~noble

# Terraform
RUN <<EOF
    wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
EOF

RUN gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

RUN echo "deb [arch=$(dpkg --print-architecture)\
        signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg]\
        https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*'\
         /etc/os-release || lsb_release -cs) main"\
        | tee /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update
RUN apt-get install terraform=1.13.1-1

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.30.1.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Utilidades

# less
RUN apt-get install less

# vim
RUN apt-get install -y vim

# npm
RUN apt-get install -y npm
RUN npm install -g npm@10.9.3

# zip
RUN apt-get install zip

# Plugins
COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins/install-plugins.sh /usr/local/bin/install-plugins.sh

RUN chmod +x /usr/local/bin/install-plugins.sh
RUN /usr/local/bin/install-plugins.sh /usr/share/jenkins/ref/plugins.txt

EXPOSE 8080 50000