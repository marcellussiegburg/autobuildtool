#!/bin/bash
PACKAGES=$1
LATEST='s/(latest: .\+)//g'
NEW_PACKAGE='s/(new package)//g'
REINSTALL='s/(reinstall)//g'
FLAGS='s/ \(-[a-zA-Z0-9\-]\+\)/ --flags=\"\1\"/g'
CHANGES='s/[a-zA-Z0-9\.\-]* -> [a-zA-Z0-9\.\-]\+//g'
CHANGES_TEXT='s/changes://g'
COMMA='s/,//g'
PREPARED=$(sed -e "$LATEST" -e "$NEW_PACKAGE" -e "$REINSTALL" -e "$FLAGS" $PACKAGES)
$(echo "echo $PREPARED" | sed -e "$CHANGES" -e "$CHANGES_TEXT" -e "$COMMA") | sed -e 's/\s\+/\n/g'