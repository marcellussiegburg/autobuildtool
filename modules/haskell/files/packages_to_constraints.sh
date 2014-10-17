#!/bin/bash
PACKAGES=$1
CONSTRAINT='s/\([a-zA-Z0-9\-]\+\)-\([0-9\.]\+\)/--constraint=\1==\2/g'
NO_CONSTRAINT='/[a-zA-Z0-9\-]\+$/d'
sed -e "$CONSTRAINT" -e "$NO_CONSTRAINT" $PACKAGES
