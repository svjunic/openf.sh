#!/bin/sh

# exit if uname is not a 'Darwin'
if [ "`uname`" != 'Darwin' ]
then
  echo 'openf.sh can execute on OS X' >&2
  exit 2
fi

# print help
help() {
  # CAUTION: do not delete tabs
  cat <<-HELP >&2
	Usage: openf [-ir] pattern [filter]
	HELP
  exit 1
}

# parse option
#   i: ignorecase
#   r: regexp
#   h: print help and exit
IGNORE=0
REGEXP=0
while getopts irh OPT
do
  case $OPT in
    i) IGNORE=1 ;;
    r) REGEXP=1 ;;
    h) help     ;;
  esac
done
shift `expr $OPTIND - 1`

# set arguments
PATTERN=$1
FILTER=$2

# halt if use unknown variable
set -u

# exit if pattern is empty
[ "$PATTERN" = '' ] && help

# default find rule
FINDRULE=name

# change to use regex
if [ "$REGEXP" -eq 1 ]
then
  FINDRULE=regex
fi

# to ignorecase
if [ "$IGNORE" -eq 1 ]
then
  FINDRULE=i$FINDRULE
fi

# find
if [ "$FILTER" = '' ]
then
  RESULT=`find . -$FINDRULE "$PATTERN" -type f -or -type l`
else
  RESULT=`find . -$FINDRULE "$PATTERN" -type f -or -type l | grep -E "$FILTER"`
fi

# get file count
COUNT=`echo "$RESULT" | wc -l`

# exit if not match to any files
# $COUNT is always over 1
if [ "$RESULT" = '' ]
then
  echo 'file not found' >&2
  exit 3
elif [ "$COUNT" -gt 1 ]
then
  echo "match to many files:"
  echo "$RESULT"
  exit 4
fi

echo "open to $RESULT"
open "$RESULT"
