#!/usr/bin/env bash

while true; do
    sudo ectool led battery red
    sleep 0.2
    sudo ectool led battery green 
    sleep 0.2
    sudo ectool led battery blue
    sleep 0.2
    sudo ectool led battery yellow
    sleep 0.2
    sudo ectool led battery white
    sleep 0.2
    sudo ectool led battery amber 
    sleep 0.2
done
