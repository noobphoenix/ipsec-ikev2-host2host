#!/bin/bash -e

# Check that the script is running as root. If not, then prompt for the sudo
# password and re-execute this script with sudo.

brand="IPSec CA HOST"

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

apt install -y strongswan
echo
echo "=== Generating CA Certificate ==="
echo

read -p "Country Abbreviations (Default: ID) : " CAID
CAID=${CAID:-'ID'}
echo
read -p "Organization : " ORG
ORG=${ORG:-'UNTIRTA'} 

ipsec pki --gen --type ecdsa --size 256 > /etc/ipsec.d/private/caKey.key
ipsec pki --self --ca --in /etc/ipsec.d/private/caKey.pem \
--type ecdsa --digest sha512 --outform pem \
--dn "C=$CAID, O=$ORG, CN=IPSec CA" > \
/etc/ipsec.d/cacerts/caCert.pem

echo
echo "=== Copying CA Certificate to the HOSTs ==="
echo

read -p "HOST1 IP adress : " HOST1
read -p "HOST2 IP adress : " HOST2

scp /etc/ipsec.d/private/caKey.key root@$HOST1:/etc/ipsec.d/private
scp /etc/ipsec.d/cacerts/caCert.pem root@$HOST1:/etc/ipsec.d/cacerts
scp /etc/ipsec.d/private/caKey.key root@$HOST2:/etc/ipsec.d/private
scp /etc/ipsec.d/cacerts/caCert.pem root@$HOST2:/etc/ipsec.d/cacerts

echo
echo "...Your CA Certification has been made and sent to the HOSTs..."





