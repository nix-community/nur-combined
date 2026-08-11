#! /usr/bin/env bash

WD="$HOME/.ludii"
mkdir -p $WD
cd $WD
exec @java@ -jar @dest@ "$@" 
