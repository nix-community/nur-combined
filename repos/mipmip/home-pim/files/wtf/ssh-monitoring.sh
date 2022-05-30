#!/bin/sh
printf "DF CCV1: "
ssh lingewoud@31.7.4.76 df -h | grep vg-root
