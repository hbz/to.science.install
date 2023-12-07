#! /bin/bash

export HERITRIX_HOME=$ARCHIVE_HOME/heritrix

./bin/heritrix -aadmin:$PASSWORD -p 8443 -b / --ssl-params $KEYSTORE,'$PASSWORD'123,'$PASSWORD'123 --jobs-dir $HERITRIX-DIR
