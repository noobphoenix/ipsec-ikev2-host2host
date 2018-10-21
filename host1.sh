#!/bin/bash -e

# Check that the script is running as root. If not, then prompt for the sudo
# password and re-execute this script with sudo.

brand="IPSec HOST1"

if [ "$(id -nu)" != "root" ]; then
    sudo -k
    pass=$(--backtitle "$brand Installer" --title "Authentication required" --passwordbox "Installing $brand requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $USER:" 12 50 3>&2 2>&1 1>&3-)
    exec sudo -S -p '' "$0" "$@" <<< "$pass"
    exit 1
fi

echo
echo "=== Installing software requirements ==="
echo

apt update -y

apt install -y strongswan libcharon-extra-plugins moreutils iptables-persistent postfix mailutils

echo
echo "=== Generating HOST1 Certificate ==="
echo

read -p "HOST1 IP Address : " HOST1
read -p "HOST2 IP Address : " HOST2
read -p "Country Abbreviations (Default: ID) : " CAID
CAID=${CAID:-'ID'}
echo
read -p "Organization : " ORG
ORG=${ORG:-'UNTIRTA'} 

ipsec pki --gen --type ecdsa --size 256 --outform pem > /etc/ipsec.d/private/host1.pem
ipsec pki --pub --type ecdsa --in \
/etc/ipsec.d/private/host1.pem | \
ipsec pki --issue --outform pem \
--digest sha512 --cacert /etc/ipsec.d/cacerts/caCert.pem \
--cakey /etc/ipsec.d/private/caKey.key \
--dn "C=$CAID, O=$ORG, CN=ubuntu" \
--san $HOST1 > /etc/ipsec.d/certs/host1.pem

echo
echo "=== Configuring IPSec Strongswan ==="
echo

echo '
net.ipv4.ip_forward = 1
net.ipv4.ip_no_pmtu_disc = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
' >> /etc/sysctl.conf

sysctl -p
sysctl --system


echo "config setup
        charondebug="all"
        uniqueids=yes
        strictcrlpolicy=no

conn host1-to-host2
  authby=secret
  left=%defaultroute
  leftid=$HOST1
  right=$HOST2
  keyexchange=ikev2
  ike=aes256-sha2_256-modp1024!
  keyingtries=0
  ikelifetime=1h
  lifetime=8h
  dpddelay=30
  dpdtimeout=120
  dpdaction=restart
  auto=start
" > /etc/ipsec.conf

echo "
$HOST1 $HOST2 : ECDSA /etc/ipsec.d/private/ubuntu-uk.pem
" > /etc/ipsec.secrets

echo
echo "=== Configuring Firewall ==="
echo


iptables -A INPUT -p udp --dport 500 --j ACCEPT
iptables -A INPUT -p udp --dport 4500 --j ACCEPT
iptables -A INPUT -p esp -j ACCEPT

echo
echo "=== Starting IPSec ==="
echo

ipsec restart

echo
echo "=== Your IPSec is started, type 'ipsec status' for more info ==="
echo