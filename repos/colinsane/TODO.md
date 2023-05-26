## BUGS
- why i need to manually restart `wireguard-wg-ovpns` on servo periodically
	- else DNS fails

## REFACTORING:
### sops/secrets
- attach secrets to the thing they're used by (sane.programs)
- rework secrets to leverage `sane.fs`
- remove sops activation script as it's covered by my systemd sane.fs impl

### roles
- allow any host to take the role of `uninsane.org`
    - will make it easier to test new services?

### upstreaming
- add updateScripts to all my packages in nixpkgs
- fix lightdm-mobile-greeter for newer libhandy
- port zecwallet-lite to a from-source build
- fix or abandon Whalebird


## IMPROVEMENTS:
### security/resilience
- validate duplicity backups!
- encrypt more ~ dirs (~/archives, ~/records, ..?)
    - best to do this after i know for sure i have good backups
- have `sane.programs` be wrapped such that they run in a cgroup?
    - at least, only give them access to the portion of the fs they *need*.
    - Android takes approach of giving each app its own user: could hack that in here.
- canaries for important services
    - e.g. daily email checks; daily backup checks

### user experience
- firefox/librewolf: don't show browserpass/sponsorblock/metamask "first run" on every boot
- moby: improve gPodder launch time
- moby: replace jellyfin-desktop with jellyfin-vue?
    - allows (maybe) to cache media for offline use
    - "newer" jellyfin client
    - not packaged for nix
- find a nice desktop ActivityPub client
- package Nix/NixOS docs for Zeal
    - install [doc-browser](https://github.com/qwfy/doc-browser)
    - this supports both dash (zeal) *and* the datasets from <https://devdocs.io> (which includes nix!)
    - install [devhelp](https://wiki.gnome.org/Apps/Devhelp)  (gnome)
- auto-mount servo
- have xdg-open parse `<repo:...> URIs (or adjust them so that it _can_ parse)
- `sane.programs`: auto-populate defaults with everything from `pkgs`
- zsh: disable "command not found" corrections
- sxmo: allow rotation to the upside-down position
    - see: <repo:mil/sxmo-utils:scripts/core/sxmo_autorotate.sh>
    - all orientations *except* upside down are supported
- sxmo: launch with auto-rotation enabled

### perf
- why does nixos-rebuild switch take 5 minutes when net is flakey?
    - trying to auto-mount servo?
    - something to do with systemd services restarting/stalling
    - maybe wireguard & its refresh operation, specifically?
- fix OOM for large builds like webkitgtk
    - these use significant /tmp space.
    - either place /tmp on encrypted-cleared-at-boot storage
        - which probably causes each CPU load for the encryption
    - **or set up encrypted swap**
        - encrypted swap could remove the need for my encrypted-cleared-at-boot stuff


## NEW FEATURES:
- add a FTP-accessible file share to servo
    - just /var/www?
- migrate MAME cabinet to nix
    - boot it from PXE from servo?
- enable IPv6
