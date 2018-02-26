#!/bin/bash
read -p "Minion ID:" MINION_ID

SYSADMIN_PKI_DIRECTORY="/home/sysadmin/pki"
SALTMASTER_PKI_DIRECTORY="/etc/salt/pki/master/minions"
REPOSITORY_DIRECTORY="/var/www/html/saltkey"
#Gen key
cd $SYSADMIN_PKI_DIRECTORY
salt-key --gen-keys=$MINION_ID
chown -R sysadmin:sysadmin *

#Copy key to salt-master pki folder
cp $SYSADMIN_PKI_DIRECTORY/${MINION_ID}.pub $SALTMASTER_PKI_DIRECTORY/$MINION_ID
chown -R root:root $SALTMASTER_PKI_DIRECTORY/*
chmod -R 644 $SALTMASTER_PKI_DIRECTORY/*

#Copy key to repository
mkdir $REPOSITORY_DIRECTORY/$MINION_ID
cp $SYSADMIN_PKI_DIRECTORY/${MINION_ID}.p* $REPOSITORY_DIRECTORY/$MINION_ID
