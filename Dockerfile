# Use Fedora 33 as base image
FROM registry.fedoraproject.org/fedora:33

# Install systemd and packages for the lab, tsflags= is set to nodocs but we need em
# first line grabs some packages to make the system more inteactive
# second line grabs gaucd dependancies
# third line grabs more guacd dependancies, wget to download tomcat and guacd, and java for tomcat
# fourth line contains a bunch of tools for compiling and flow, iproute and cnat aren't needed but they're cool i think
RUN dnf install -y systemd openssh-server neofetch bpytop man sudo vim passwd \ 
    cairo-devel libjpeg-turbo-devel libpng-devel libtool libuuid-devel \
    libssh2-devel pango-devel openssl-devel wget java-1.8.0-openjdk-devel \
    unzip make zsh curl nmap-ncat iproute nginx git maven cronie --setopt='tsflags=' && \
    dnf clean all

# environment variables needed for guac and tomcat to function
RUN export CATALINA_HOME=/var/lib/tomcat && \
    export JAVA_HOME=/usr/bin/java && \
    export GUACAMOLE_HOME=/etc/guacamole

# Create user with password
RUN useradd -m containerized && \
    usermod -aG wheel containerized && \
    echo "containerized" | passwd containerized --stdin

# set zsh as default console for root and containerized
RUN echo -e "/usr/bin/zsh\n" | lchsh containerized && \
    echo -e "/usr/bin/zsh\n" | lchsh root

# oh my zsh for pretty colors
USER containerized
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
USER root
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Time to get tomcat and guac 
RUN cd /opt && \ 
    wget \
       https://apache.org/dyn/closer.lua/guacamole/1.4.0/source/guacamole-server-1.4.0.tar.gz?action=download \
       https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.64/bin/apache-tomcat-9.0.64.zip && \
    mv guacamole-server-1.4.0.tar.gz?action=download guacamole-server.1.4.0.tar.gz

# build guacd
RUN cd /opt && \
    tar -xzf guacamole-server.1.4.0.tar.gz && \
    cd guacamole-server-1.4.0 && \
    ./configure && \
    make && \
    make install && \
    ldconfig 

# build guac client
RUN cd /opt && \
    wget https://apache.org/dyn/closer.lua/guacamole/1.4.0/source/guacamole-client-1.4.0.tar.gz?action=download && \
    tar xzf guacamole-client-1.4.0.tar.gz?action=download && \
    cd guacamole-client-1.4.0 && \
    mvn package

# move tomcat and guac client to proper spot 
RUN cd /opt && \
    unzip apache-tomcat-9.0.64.zip && \
    mv apache-tomcat-9.0.64 /var/lib/tomcat && \
    mv /opt/guacamole-client-1.4.0/guacamole/target/guacamole-1.4.0.war /var/lib/tomcat/webapps/guacamole.war

# clean up, correct permission setting for scripts, and services
RUN rm -r /opt/* && \
    chmod +x /var/lib/tomcat/bin/* && \
    systemctl enable nginx.service && \
    systemctl enable crond.service

# Basic Authentication
RUN mkdir /etc/guacamole && \
    curl --output /etc/guacamole/user-mapping.xml https://gist.githubusercontent.com/Shinwaffle/0668ee3d8c0872c15cafee7b7afb6abd/raw/9bb2bf00d73ed15cdedbb368af393d29303418fc/user-mapping.xml && \
    echo -e "guacd-hostname: localhost\nguacd-port: 4822" > /etc/guacamole/guacamole.properties

# nginx forwards traffic to tomcat, allows for nice logging
RUN curl --output /etc/nginx/nginx.conf https://gist.githubusercontent.com/Shinwaffle/42b5e7c285a61626ab2ce63362958676/raw/6a02c163d04f62888dca663e9b4984fc965bbdea/nginx.conf && \
    curl --output /etc/nginx/conf.d/guacamole.conf https://gist.githubusercontent.com/Shinwaffle/aba8988816a17e8514ab292bbce53d8c/raw/648e5333eae6bd145a2fb52061a6fead26581f94/guacamole.conf

# Use systemd as command
CMD [ "/usr/sbin/init" ]
#nginx port
EXPOSE 80
