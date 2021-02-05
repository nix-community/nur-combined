#!/usr/bin/env bash

export DEFAULT_USER=lucasew
export VPS_IP=192.168.69.1
export NB_IP=192.168.69.2
TARGET=$1;shift
COMMAND=$1;shift

case $TARGET in
    vps)
        case $COMMAND in
            switch)
                nixos-rebuild switch --flake .#vps --target-host $DEFAULT_USER@$VPS_IP --build-host localhost
            ;;
            reboot)
                ssh $DEFAULT_USER@$VPS_IP reboot
            ;;
            htop)
                ssh $DEFAULT_USER@$VPS_IP -t htop
            ;;
            eip)
                echo $(ssh $DEFAULT_USER@$VPS_IP curl ifconfig.me 2> /dev/null)
            ;;
        esac
    ;;
    nb)
        case $COMMAND in
            switch)
                nixos-rebuild switch --flake .#acer-nix --target-host $DEFAULT_USER@$NB_IP --build-host $DEFAULT_USER@$NB_IP
            ;;
            reboot)
                ssh $DEFAULT_USER@$NB_IP reboot
            ;;
            htop)
                ssh $DEFAULT_USER@$NB_IP -t htop
            ;;
            eip)
                echo $(ssh $DEFAULT_USER@$NB_IP curl ifconfig.me 2> /dev/null)
            ;;
        esac
    ;;
esac
