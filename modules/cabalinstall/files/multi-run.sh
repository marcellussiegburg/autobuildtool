#!/bin/bash
FULL_LOG=~/__tmp__file.log
BASIC_LOG=~/__tmp__file_err.log

MESSAGE="$1"
COMMAND="$2"
MAX_RUNS="$3"
RUN="$4"

eval "$COMMAND" 2>> $FULL_LOG | tee -a $FULL_LOG > $BASIC_LOG
EXIT=${PIPESTATUS[0]}

((RUN++))
if [ $RUN -lt $MAX_RUNS ] && tail -n 1 $FULL_LOG | eval grep --quiet $MESSAGE ; then
    cat $BASIC_LOG
    rm -f $BASIC_LOG $FULL_LOG
    bash "$0" "$MESSAGE" "$COMMAND" "$MAX_RUNS" "$RUN"
    exit $?
else
    cat $FULL_LOG
    rm -f $BASIC_LOG $FULL_LOG
    exit $EXIT
fi







