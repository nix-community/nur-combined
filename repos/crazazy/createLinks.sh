#!/usr/bin/env bash
CONFIG=$HOME/.config
CURRENT=$(dirname $0| sed -e s@\\.@$(pwd)@g)
for i in $(ls $CURRENT/local); do
	ln -s $CURRENT/local/$i $CONFIG
done
