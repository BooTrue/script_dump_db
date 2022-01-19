#!/bin/bash

DATADIR="$1"
MTIME="$2"

# Ignore these databases (space separated)
IGNORE="information_schema mysql performance_schema"

# Paths to programs
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

# Misc vars
NOW="$(date +"%d-%m-%Y-%H")"

DBS="$($MYSQL -Bse 'show databases')"

for DB in $DBS ; do
        if [[ "$IGNORE" =~ "$DB" ]] ; then
                continue
        fi

        TABLES="$($MYSQL -Bse 'show tables from '$DB)"
        for TABLE in $TABLES ; do
                FILE="$DATADIR/$DB.$NOW.${TABLE}.sql.gz"
                $MYSQLDUMP $DB $TABLE | $GZIP -9 > $FILE
        done

done

find "$DATADIR" -type f -name "*.sql.gz" -mtime "$MTIME" -exec rm {} \;

exit 0
