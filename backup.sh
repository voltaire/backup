#!/bin/bash

# Minecraft Backup Script                  
# Author: Mark Ide <cranstonide@gmail.com> 
# Github: https://github.com/cranstonide/linux-minecraft-scripts
hostname=`hostname`

# Move into the directory with all Linux-Minecraft-Scripts
cd "$( dirname $0 )"

# Read configuration file
if [ "$hostname" == "ichiro" ]
    then source mc-config.cfg
elif [ "$hostname" == "voltaire" ]
    then source ftb-config.cfg
fi

# We need to first put the server in readonly mode to reduce the chance of backing up half of a chunk. 
screen -p 0 -S voltairemc  -X eval "stuff \"save-off\"\015"
screen -p 0 -S voltairemc -X eval "stuff \"save-all\"\015"

# Wait a few seconds to make sure that Minecraft has finished backing up.
sleep 5

# Create a copy for the most recent server image directory (its a convenient way to recover 
# a single players' data or chunks without unzipping the whole archive). If you don't need a 
# directory with the most recent image, you may comment this section out.
rm -rf $backupDest/$serverNick-most-recent
mkdir $backupDest/$serverNick-most-recent
cp -R $minecraftDir/* $backupDest/$serverNick-most-recent

# Create an archived copy in .tar.gz format.
# rm -rf $backupDest/$serverNick-$backupStamp.tar.gz
tar -czf $backupDest/$serverNick-$backupStamp.tar.gz $minecraftDir/*
rsync -a $backupDest/$serverNick-$backupStamp.tar.gz backups:/home/backups/mc-voltaire-sh/backups/

# Don't forget to take the server out of readonly mode.
screen -p 0 -S voltairemc -X eval "stuff \"save-on\"\015"

# Wait a second for the gnu-screen to allow another stuffing and optionally alert users that the backup has been completed.
sleep 1
screen -p 0 -S voltairemc -X eval "stuff \"say Backup has been completed.\"\015"

# (Optionally) Remove all old (older than 7 days) backups to cut down on disk utilization. 
find $backupDest* -mtime +2 -exec rm {} -rf \;

