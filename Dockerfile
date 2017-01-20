# Install all the RPM packages that puppet will install and disable
# metadata updates so that the environment can be joined to puppet
# and run without error in an offline environment
FROM picoded/centos-systemd:latest
MAINTAINER Geoff Williams <geoff.williams@puppet.com>
RUN \
  yum update -y
RUN \
  yum groupinstall -y "Development Tools" && \
  yum install -y cronie \
    git \
    zlib-devel \
    which \
    gpm-libs \
    vim-filesystem \
    vim-common \
    vim-enhanced sudo \
    links \
    wget \
    policycoreutils \
    policycoreutils-restorecond \
    iptables

# upgrade ruby (sigh)
RUN adduser showoff
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2.6"
RUN usermod -aG rvm showoff

USER showoff
RUN /bin/bash -l -c "yes| gem install showoff"

USER root
# setup presentation
RUN \
  mkdir /home/showoff/presentation && \
  echo "metadata_expire=never" >> /etc/yum.conf && \
  echo "LANG=en_US.UTF-8" >> /etc/environment && \
  echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
  echo "export PATH=/opt/puppetlabs/puppet/bin/:${PATH}" >> /etc/profile.d/zz_docker_puppet.sh && \
  echo "export TERM=xterm"  >> /etc/profile.d/zz_docker_puppet.sh

# systemd for showoff  
ADD showoff.service /etc/systemd/system
ADD presentation /home/showoff/presentation
RUN systemctl enable /etc/systemd/system/showoff.service

# showoff
EXPOSE 9090

# incase you want to demo a web server
EXPOSE 80

# ...or a tomcat/java app
EXPOSE 8080
