#!/bin/bash

DATADIR="$1"
MTIME="$2"

# MySQL settings
MYSQL_USER="root"
MYSQL_PASS=""
MYSQL_HOST="localhost"

# Ignore these databases (space separated)
IGNORE="information_schema mysql performance_schema"

# Paths to programs
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

# Misc vars
NOW="$(date +"%d-%m-%Y-%H")"

MYSQL_PERMS="-u $MYSQL_USER -h $MYSQL_HOST"

if [ "$MYSQL_PASS" ] ; then
        MYSQL_PERMS+=" -p$MYSQL_PASS"
fi

# Check backup path and create it if necessary

DBS="$($MYSQL $MYSQL_PERMS -Bse 'show databases')"

for DB in $DBS ; do
        if [[ "$IGNORE" =~ "$DB" ]] ; then
                continue
        fi

        TABLES="$($MYSQL $MYSQL_PERMS -Bse 'show tables from '$DB)"
        for TABLE in $TABLES ; do
                FILE="$DATADIR/$DB.$NOW.${TABLE}.sql.gz"
                $MYSQLDUMP $MYSQL_PERMS $DB $TABLE | $GZIP -9 > $FILE
        done

done

find "$DATADIR" -type f -name "*.sql.gz" -mtime "$MTIME" -exec rm {} \;

exit 0
