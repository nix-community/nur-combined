# Nix-config

My NixOS-based system configuration files.

Currently only used as an experiment to self-host a new server.

## Steps

First build using flakes:

```sh
sudo nixos-rebuild switch --flake .
```

Secondly, take care of a few manual steps:

* Configure Gitea and Drone
* Configure Lohr webhook and SSH key
* Configure Jellyfin
* Configure Prowlarr,Jackett and NZBHydra2
* Configure Sonarr, Radarr, Bazarr
* Configure Transmission's webui port
* Configure Quassel user
* Configure Flood account
