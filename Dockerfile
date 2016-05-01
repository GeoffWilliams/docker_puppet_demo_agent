FROM picoded/centos-systemd:latest
MAINTAINER Geoff Williams <geoff.williams@puppet.com>
RUN \
  yum update -y && \
  yum install -y cronie \
    ruby ruby-devel git zlib-devel ImageMagick-devel \
    ImageMagick which && \
  yum groupinstall -y "Devlopment Tools" \
  yes | gem install showoff rmagick \
  adduser showoff

# systemd for showoff  
ADD showoff.service /etc/systemd/system
ADD presentation /home/showoff
RUN systemctl enable /etc/systemd/system/showoff.service

# showoff
EXPOSE 9090
