#!/bin/bash

./bin/heritrix -aadmin:$HERITRIX_PASSWORD -p 8443 -b / --ssl-params $KEYSTORE,$STOREPASS,$KEYPASS --jobs-dir $HERITRIX_DIR
