# Install all the RPM packages that puppet will install and disable
# metadata updates so that the environment can be joined to puppet
# and run without error in an offline environment
FROM picoded/centos-systemd:latest
MAINTAINER Geoff Williams <geoff.williams@puppet.com>
RUN \
  yum update -y && \
  yum groupinstall -y "Development Tools" && \
  yum install -y cronie \
    ruby \
    ruby-devel \
    git \
    zlib-devel \
    which \
    gpm-libs \
    vim-filesystem \
    vim-common \
    vim-enhanced sudo && \
  yes | gem install showoff && \
  adduser showoff && \
  mkdir /home/showoff/presentation && \
  systemctl disable firewalld && \
  echo "metadata_expire=never" >> /etc/yum.conf \
  echo 'export LC_ALL="en_US.UTF-8"' >> /etc/profile.d/zz_docker_puppet.sh && \
  echo 'export PATH=/opt/puppetlabs/puppet/bin/:${PATH}' >> /etc/profile.d/zz_docker_puppet.sh && \
  echo 'export TERM=xterm' >> /etc/profile.d/zz_docker_puppet.sh

# systemd for showoff  
ADD showoff.service /etc/systemd/system
ADD presentation /home/showoff/presentation
RUN systemctl enable /etc/systemd/system/showoff.service

# showoff
EXPOSE 9090
