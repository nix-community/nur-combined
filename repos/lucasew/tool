#!/usr/bin/env bash

export DEFAULT_USER=lucasew
export VPS_IP=192.168.69.1
export NB_IP=192.168.69.2
TARGET=$1;shift
COMMAND=$1;shift

case $TARGET in
    vps)
        case $COMMAND in
            build)
                nixos-rebuild build --flake .#vps || exit 1
            ;;
            switch)
                $0 vps build
                nix-copy-closure $DEFAULT_USER@$VPS_IP $(readlink result)
                ssh $DEFAULT_USER@$VPS_IP -t tmux new sudo $(readlink result)/bin/switch-to-configuration switch
            ;;
            reboot)
                ssh $DEFAULT_USER@$VPS_IP -t tmux new sudo halt --no-wall --reboot
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
            build)
                nixos-rebuild build --flake .#acer-nix
            ;;
            switch)
                $0 nb build
                nix-copy-closure $DEFAULT_USER@$NB_IP $(readlink result)
                ssh $DEFAULT_USER@$NB_IP -t tmux new sudo $(readlink result)/bin/switch-to-configuration switch
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
