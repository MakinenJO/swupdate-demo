#!/bin/sh

echo "This should only run on postinstall: $1"

echo "File created by script_postinst.sh, arg1: $1, $(date)" > /scriptfile_postinstall
