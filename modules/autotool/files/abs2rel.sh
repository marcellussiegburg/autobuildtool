#!/bin/bash
function replace_links {
    local ORIGINAL_PATH="$1/"
    shift
    local SUBSTITUTION_PATH=""
    for i in "$@"
    do
	SUBSTITUTION_PATH="../$SUBSTITUTION_PATH"
    done
    if [ $# -ge 1 ]
    then
	replace_links "$ORIGINAL_PATH$@"
    fi
    local ORIGINAL_PATH_ESCAPED=$(echo "=\"$ORIGINAL_PATH" | sed -e 's/[]\/()$*.^|[]/\\&/g')
    local SUBSTITUTION_PATH_ESCAPED=$(echo "=\"$SUBSTITUTION_PATH" | sed -e 's/[]\/()$*.^|[]/\\&/g')
    grep -Zlr --include=*.html -F $ORIGINAL_PATH . | xargs -0 -r sed -s -i -e 's/'$ORIGINAL_PATH_ESCAPED'/'$SUBSTITUTION_PATH_ESCAPED'/g'
}

function recurse_path {
    for i in $(find * -maxdepth 0 -type d)
    do
	cd "$i"
	recurse_path "$@" "$i"
	cd ..
    done
    replace_links "$@"
}

BASE_PATH=$1
cd $BASE_PATH
recurse_path $BASE_PATH
