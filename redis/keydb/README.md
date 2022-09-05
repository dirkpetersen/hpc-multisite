# configure keydb active-active cluster 

KeyDB is a potential redis replacement as it supports multi-threading and is planning to support flash using RocksDB 



bring up 2 or more nano instances with Ubuntu 20.04 on linode

use the config.sh script or follow the instructions below. Note that "storage-provider flash" is not yet available in version 6.3.1. If you need flash you could use `kvrocks` as it as a redis compatible API but used the RocksDB storage engine 

install packages 

```
echo "deb https://download.keydb.dev/open-source-dist $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/keydb.list
sudo wget -O /etc/apt/trusted.gpg.d/keydb.gpg https://download.keydb.dev/open-source-dist/keyring.gpg
sudo apt update
sudo apt install keydb
```

open firewall ports 

```
iptables -A INPUT -p tcp --dport 6379 -j ACCEPT
iptables -A INPUT -p tcp --dport 16379 -j ACCEPT
```

edit /etc/keydb/keydb.conf on all systems 

we have a total of 3 systems and the current one has ip address: 222.222.222.222

```
#storage-provider flash /var/lib/keydb/flash
dir /var/lib/keydb
daemonize yes
pidfile /var/run/keydb/keydb-server.pid
loglevel debug
logfile /var/log/keydb/keydb-server.log
maxmemory 750M
maxmemory-policy allkeys-lru
protected-mode yes
requirepass xxxxxxxxxx
masterauth xxxxxxxxxx
server-threads 4
replica-read-only no
active-replica yes
multi-master yes
replicaof 111.111.111.111 6379
replicaof 333.333.333.333 6379
```
