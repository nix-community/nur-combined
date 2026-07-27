#!/usr/bin/env bash

CURRENT_LIGHT=$(sudo ectool pwmgetkblight | cut -d' ' -f 5)

echo $CURRENT_LIGHT >> /home/mia/Scripts/output.txt

if [[ $CURRENT_LIGHT -eq "" ]]
then
    CURRENT_LIGHT=0
fi

if [[ $CURRENT_LIGHT -eq 0 ]];
then
    FIRST_LIGHT_VALUE=100
    SECOND_LIGHT_VALUE=0
else
    FIRST_LIGHT_VALUE=$CURRENT_LIGHT
    SECOND_LIGHT_VALUE=0
fi

count=0
while [[ $count -lt $1 ]];
do
    sudo ectool pwmsetkblight $FIRST_LIGHT_VALUE
    sleep 0.13
    sudo ectool pwmsetkblight $SECOND_LIGHT_VALUE
    sleep 0.13
    ((count=count+1))
done

sudo ectool pwmsetkblight $CURRENT_LIGHT
