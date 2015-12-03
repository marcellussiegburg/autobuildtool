#!/bin/bash
PACKAGES=$1
LATEST='s/(latest: .\+)//g'
NEW_PACKAGE='s/(new package)//g'
NEW_VERSION='s/(new version)//g'
REINSTALL='s/(reinstall)//g'
ADDED="s/added//g"
FLAGS='s/ \(-[a-zA-Z0-9\-]\+\)/ --flags=\"\1\"/g'
ENABLE_FLAGS='s/ +\([a-zA-Z0-9\-]\+\)/ --flags=\"\1\"/g'
CHANGES='s/[a-zA-Z0-9\.\-]\+ -> [a-zA-Z0-9\.\-]\+//g'
CHANGES_TEXT='s/changes://g'
COMMA='s/,//g'
PREPARED=$(grep -v "installed:" $PACKAGES | grep -v "reinstall anyway." | sed -e "$BEGIN_ARROW" -e "$END_ARROW" -e "$LATEST" -e "$NEW_PACKAGE" -e "$NEW_VERSION" -e "$REINSTALL" -e "$FLAGS" -e "$ENABLE_FLAGS" -e "$ADDED")
$(echo "echo $PREPARED") | sed -e "$CHANGES" -e "$CHANGES_TEXT" -e "$COMMA" | sed -e 's/\s\+/\n/g'
