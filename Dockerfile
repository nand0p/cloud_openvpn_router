FROM centos:latest
MAINTAINER Fernando Jose Pando <nando@hex7.com>

RUN yum -y install epel-release strace net-tools
RUN yum -y install openvpn

RUN printf "#daemon\n\
verb 6\n\
dev-type tun\n\
dev-node /dev/net/tun\n\
log-append /var/log/openvpn.log\n\
user nobody\n\
group nobody\n\
writepid /var/run/openvpn_server.pid\n\
script-security 3\n\
keepalive 10 60\n\
ping-timer-rem\n\
persist-tun\n\
persist-key\n\
proto tcp-server\n\
cipher AES-128-CBC\n\
auth SHA1\n\
ifconfig 10.10.11.1 10.10.11.2\n\
lport 443\n\
management /tmp/server.sock unix\n\
#secret /etc/openvpn/server.secret\n\
" > /etc/openvpn/openvpn.conf

RUN mkdir -v /dev/net && mknod /dev/net/tun c 10 200

CMD ["openvpn", "--config", "/etc/openvpn/openvpn.conf"]
