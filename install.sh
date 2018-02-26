#!/bin/bash
SALTMINION_PKI_DIRECTORY="/etc/salt/pki/minion"
#Read minion ID from keyboard
read -p "MINION_ID: " MINION_ID
if [ -e minion.conf ];then
    echo "id: $MINION_ID" >> minion.conf
fi
#Install wget if not installed
if ! [ -e /usr/bin/wget ];then
    yum install -y wget
fi

#wget key from repo  
wget http://192.168.158.238/saltkey/${MINION_ID}/${MINION_ID}.pub
wget http://192.168.158.238/saltkey/${MINION_ID}/${MINION_ID}.pem

if ! [ -e ${MINION_ID}.pub -a -e ${MINION_ID}.pem ];then
    echo "Erorr: Can not wget keypair from repos"
    exit 
fi

# Install Python2.7
if ! [ -e /usr/bin/python2.7 ]; then
  tar xzf Python-2.7.14.tgz && cd Python-2.7.14 && ./configure --enable-optimizations && make altinstall && ln -s /usr/local/bin/python2.7 /usr/bin/ && cd ..
fi
# Insert hosts file
if ! grep -q "192.168.158.238 SaltMaster" /etc/hosts; then
  echo "192.168.158.238 SaltMaster" >> /etc/hosts
fi
if ! grep -q "192.168.158.238 RedisHost" /etc/hosts; then
  echo "192.168.158.238 RedisHost" >> /etc/hosts
fi
# Insert Vega Local Repo
if grep -q -i "release 7" /etc/redhat-release; then
  cp ./Vega-Repo-7.repo /etc/yum.repos.d/Vega-Repo.repo
fi
if grep -q -i "release 6" /etc/redhat-release; then
  cp ./Vega-Repo-6.repo /etc/yum.repos.d/Vega-Repo.repo
fi
# Install Salt-Minion
yum -y install salt-minion
cp ./minion.conf /etc/salt/minion.d/ && chown -R root:root /etc/salt/minion.d/* && chmod -R 600 /etc/salt/minion.d/*
#cp ./minion_master.pub $SALTMINION_PKI_DIRECTORY/
cp ./${MINION_ID}.pub $SALTMINION_PKI_DIRECTORY/minion.pub
cp ./${MINION_ID}.pem $SALTMINION_PKI_DIRECTORY/minion.pem
chown -R root:root $SALTMINION_PKI_DIRECTORY/* && chmod -R 600 $SALTMINION_PKI_DIRECTORY/*

# Start Salt-Minion
if grep -q -i "release 7" /etc/redhat-release; then
  systemctl start salt-minion && systemctl enable salt-minion
  cd ./redis-2.10.6
  /usr/bin/python2.7 setup.py install
  systemctl restart salt-minion
fi
if grep -q -i "release 6" /etc/redhat-release; then
  /etc/init.d/salt-minion start && chkconfig --add salt-minion && chkconfig salt-minion on
  cd ./redis-2.10.6
  /usr/bin/python2.7 setup.py install
  /etc/init.d/salt-minion restart
fi

