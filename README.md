# voltaireMC backups system

## Overview

This system will be called every so often by cron, rsyncing any tracked files to a staging server where the world directories are packed into tarballs and config files are tracked by git.

### crontab

```
30 5 * * * /srv/minecraft/bu/backup.sh >> /srv/minecraft/bu/logs/backup.log
```
