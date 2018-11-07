#!/bin/sh

BACKUP_NAME=$(heroku pg:backups -a $HEROKU_APP  | grep Completed | head -n 1 | cut -f1 -d' ')
DUMP_FILE=/tmp/${BACKUP_NAME}.sql
LOCK_FILE=/tmp/copy.lock

if [ -e $LOCK_FILE ]; then
  echo "Another copy process is already running. Stopping..."
  exit 0
fi

touch $LOCK_FILE

if [ -e $DUMP_FILE ]; then
  echo "Backup '$BACKUP_NAME' was already restored. Skipping..."
  exit 0
fi

echo "Downloading backup $BACKUP_NAME from Heroku app '$HEROKU_APP'"
heroku pg:backups:url $BACKUP_NAME -a $HEROKU_APP | xargs wget --quiet -O $DUMP_FILE

echo "Restoring backup on remote host"
pg_restore --clean --verbose --clean --no-acl --no-owner -j 12 -U $TARGET_USER -d $TARGET_DB -h $TARGET_HOST $DUMP_FILE

echo "Backup '$BACKUP_NAME' successfully restored!"

rm -f $LOCK_FILE

exit 0
