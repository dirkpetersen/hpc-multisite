#! /bin/bash

cfg() {
  echo "$1" >> /etc/keydb/keydb.conf
}

if [[ -f /etc/keydb/keydb.conf.org ]]; then
  echo "already configured, keydb.conf.org exists"
  exit
fi

echo "deb https://download.keydb.dev/open-source-dist $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/keydb.list
sudo wget -O /etc/apt/trusted.gpg.d/keydb.gpg https://download.keydb.dev/open-source-dist/keyring.gpg
sudo apt update
sudo apt install keydb

iptables -A INPUT -p tcp --dport 6379 -j ACCEPT
iptables -A INPUT -p tcp --dport 16379 -j ACCEPT

mv /etc/keydb/keydb.conf /etc/keydb/keydb.conf.org
grep  -v ^# /etc/keydb/keydb.conf.org | grep -v ^$ > /etc/keydb/keydb.conf.default

echo "### settings for KeyDB" >> /etc/sysctl.conf
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1
echo never > /sys/kernel/mm/transparent_hugepage/enabled
mkdir -p /var/lib/keydb/flash
chmod 770 /var/lib/keydb/flash
chown keydb:keydb /var/lib/keydb/flash

cfg "# storage-provider flash /var/lib/keydb/flash"
cfg "dir /var/lib/keydb"
cfg "daemonize yes"
cfg "pidfile /var/run/keydb/keydb-server.pid"
cfg "loglevel notice"
cfg "logfile /var/log/keydb/keydb-server.log"
cfg "maxmemory 750M"
cfg "maxmemory-policy allkeys-lru"
cfg "protected-mode yes"
cfg "requirepass XXXXXXXXX"
cfg "masterauth XXXXXXXXX"
cfg "server-threads 4"
cfg "replica-read-only no"
cfg "active-replica yes"
cfg "multi-master yes"
cfg "#replicaof x.x.x.x 6379"

systemctl restart keydb
systemctl status keydb

