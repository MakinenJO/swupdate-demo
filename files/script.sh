#!/bin/sh

# SWUpdate passes ‘preinst’, ‘postinst’ or ‘postfailure’ as first argument to the script.
# If the data attribute is defined, its value is passed as the last argument(s) to the script.

echo "Hello swupdate: $1"

argument="no_arg"

if [ ! -z "$2" ]; then
    echo "$1 Argument supplied: $2"
    argument="$2"
fi

echo "File created by script.sh, arg: $argument, $(date)" > /scriptfile-$1-$argument
