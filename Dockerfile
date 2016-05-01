FROM picoded/centos-systemd:latest
MAINTAINER Geoff Williams <geoff.williams@puppet.com>
RUN \
  yum update -y && \
  yum groupinstall -y "Development Tools" && \
  yum install -y cronie \
    ruby ruby-devel git zlib-devel which && \
  yes | gem install showoff && \
  adduser showoff && \
  mkdir /home/showoff/presentation

# systemd for showoff  
ADD showoff.service /etc/systemd/system
ADD presentation /home/showoff/presentation
RUN systemctl enable /etc/systemd/system/showoff.service

# showoff
EXPOSE 9090
