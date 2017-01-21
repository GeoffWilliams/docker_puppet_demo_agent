# Install all the RPM packages that puppet will install and disable
# metadata updates so that the environment can be joined to puppet
# and run without error in an offline environment
FROM centos:centos7

# from https://hub.docker.com/r/picoded/centos-systemd/ but switched
# to upstream centos to keep image size down
ENV container docker
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]


MAINTAINER Geoff Williams <geoff.williams@puppet.com>
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
    iptables && \
  yum clean all

# upgrade ruby (sigh)
RUN adduser showoff
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2.6 && rvm cleanup all"
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
