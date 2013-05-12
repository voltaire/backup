#!/bin/bash

# Minecraft Backup Script                  
# Author: Mark Ide <cranstonide@gmail.com> 
# Github: https://github.com/cranstonide/linux-minecraft-scripts

# Move into the directory with all Linux-Minecraft-Scripts
cd "$( dirname $0 )"

# Read configuration file
if [ "$(whoami)" == "minecraft" ]
    then source mc-config.cfg
    elif [ "$(whoami)" == "ftb" ]
    then source ftb-config.cfg
fi

tarDir=$(basename $minecraftDir)

# We need to first put the server in readonly mode to reduce the chance of backing up half of a chunk. 
screen -p 0 -S $(whoami) -X eval "stuff \"save-off\"\015"
screen -p 0 -S $(whoami) -X eval "stuff \"save-all\"\015"

# Wait a few seconds to make sure that Minecraft has finished backing up.
sleep 5

# Create a copy for the most recent server image directory (its a convenient way to recover 
# a single players' data or chunks without unzipping the whole archive). If you don't need a 
# directory with the most recent image, you may comment this section out.
rm -rf $localBUDest/$serverNick-most-recent
mkdir $localBUDest/$serverNick-most-recent
cp -R $minecraftDir/* $localBUDest/$serverNick-most-recent

# Create an archived copy in .tar.gz format.
# rm -rf $localBUDest/$serverNick-$backupStamp.tar.gz
nice tar -czf $localBUDest/$serverNick-$backupStamp.tar.gz -C $HOME/$tarDir/ .
#cp $localBUDest/$serverNick-$backupStamp.tar.gz $tahoedir/
/usr/local/bin/boto-rsync -g public-read $localBUDest/$serverNick-$backupStamp.tar.gz gs://voltairemc/$dodir
#rsync -a $localBUDest/$serverNick-$backupStamp.tar.gz backups:$remoteBUDest

# Don't forget to take the server out of readonly mode.
screen -p 0 -S $(whoami) -X eval "stuff \"save-on\"\015"

# Wait a second for the gnu-screen to allow another stuffing and optionally alert users that the backup has been completed.
sleep 1
screen -p 0 -S $(whoami) -X eval "stuff \"say Backup has been completed.\"\015"

# (Optionally) Remove all old (older than 7 days) backups to cut down on disk utilization. 
