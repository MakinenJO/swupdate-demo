#!/bin/sh

echo "This should only run on preinstall: $1"

echo "File created by script_preinst.sh, arg1: $1, $(date)" > /scriptfile_preinstall
