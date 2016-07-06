FROM centos:latest
MAINTAINER Fernando Jose Pando <nando@hex7.com>

ADD openvpn.conf /etc/openvpn/openvpn.conf

RUN yum -y install epel-release rsyslog strace
RUN rm -v /etc/rsyslog.d/listen.conf
RUN /usr/sbin/rsyslogd
RUN yum -y install openvpn
RUN mkdir /dev/net && mknod /dev/net/tun c 10 200

EXPOSE 443
RUN openvpn --config /etc/openvpn/openvpn.conf
