# IPSec IKEv2 on Host-to-Host Configuration

secure connection between two hosts using ipsec transport mode. This scenario enables the end-to-end security over internet. 

**IPSec** 

IP Security (IPsec) provides confidentiality, data integrity, access
control, and data source authentication to IP datagrams.  These
services are provided by maintaining shared state between the source
and the sink of an IP datagram.  This state defines, among other
things, the specific services provided to the datagram, which
cryptographic algorithms will be used to provide the services, and
the keys used as input to the cryptographic algorithms.

## Requirements:
- CA HOST (Ubuntu 16.04)
- HOST1 (Ubuntu 16.04)
- HOST2 (Ubuntu 16.04)

## Supported Operating System:
- Ubuntu 16.04 (Tested)
- Ubuntu 14.04

## ToDo 
Download the script and give it execute permissions:

**CA HOST**
```
https://raw.githubusercontent.com/noobphoenix/ipsec-ikev2-host2host/master/cahost.sh
chmod u+x cahost.sh
```

**Login to HOST1**
```
https://raw.githubusercontent.com/noobphoenix/ipsec-ikev2-host2host/master/host1.sh
chmod u+x host1.sh
```
**Login to HOST2**
```
https://raw.githubusercontent.com/noobphoenix/ipsec-ikev2-host2host/master/host2.sh
chmod u+x host2.sh
```

**check Connection**
```
ipsec status
```
