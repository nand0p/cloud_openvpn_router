Vagrant.configure(2) do |config|
  config.vm.define "cloud-openvpn-router" do |ovpn|
    ovpn.vbguest.auto_update = true
    ovpn.vm.box = "centos/7"
    ovpn.vm.hostname = "cloud-openvpn-router"
    ovpn.vm.post_up_message = "cloud-openvpn-router is up."
    ovpn.vm.network "forwarded_port", guest: 443, host: 443
    ovpn.vm.provider "virtualbox" do | vbox |
      vbox.name = 'cloud-openvpn-router'
    end
    ovpn.vm.provision "shell", inline: <<-SHELL
      yum -y install epel-release strace net-tools
      yum -y install openvpn
      printf "daemon
verb 6
dev-type tun
dev-node /dev/net/tun
log-append /var/log/openvpn.log
user nobody
group nobody
writepid /var/run/openvpn_server.pid
script-security 3
keepalive 10 60
ping-timer-rem
persist-tun
persist-key
proto tcp-server
cipher AES-128-CBC
auth SHA1
ifconfig 10.10.11.1 10.10.11.2
lport 443
management /tmp/server.sock unix
#secret /etc/openvpn/server.secret" > /etc/openvpn/openvpn.conf
      openvpn --config /etc/openvpn/openvpn.conf
    SHELL
  end
end
