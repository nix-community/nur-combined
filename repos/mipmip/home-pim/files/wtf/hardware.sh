#!/bin/sh
printf "Temp"
sensors radeon-pci-0500 | grep temp1 | tr -s " " | sed 's/temp1/radion/g'


