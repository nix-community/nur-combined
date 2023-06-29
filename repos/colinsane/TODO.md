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
- split out a trust-dns module
  - see: <https://github.com/NixOS/nixpkgs/pull/205866#issuecomment-1575753054>
- split out a sxmo module usable by NUR consumers
- bump nodejs version in lemmy-ui
- add updateScripts to all my packages in nixpkgs
- fix lightdm-mobile-greeter for newer libhandy
- port zecwallet-lite to a from-source build
- REVIEW/integrate jellyfin dataDir config: <https://github.com/NixOS/nixpkgs/pull/233617>
- remove `libsForQt5.callPackage` broadly: <https://github.com/NixOS/nixpkgs/issues/180841>


## IMPROVEMENTS:
### security/resilience
- validate duplicity backups!
- encrypt more ~ dirs (~/archives, ~/records, ..?)
    - best to do this after i know for sure i have good backups
- have `sane.programs` be wrapped such that they run in a cgroup?
    - at least, only give them access to the portion of the fs they *need*.
    - Android takes approach of giving each app its own user: could hack that in here.
    - **systemd-run** takes a command and runs it in a temporary scope (cgroup)
      - presumably uses the same options as systemd services
      - see e.g. <https://github.com/NixOS/nixpkgs/issues/113903#issuecomment-857296349>
    - flatpak does this, somehow
    - apparmor?  SElinux?  (desktop) "portals"?
    - see Spectrum OS; Alyssa Ross; etc
- canaries for important services
    - e.g. daily email checks; daily backup checks
    - integrate `nix check` into Gitea actions?

### user experience
- neovim: set up language server (lsp; rnix-lsp; nvim-lspconfig)
- firefox/librewolf: don't show browserpass/sponsorblock/metamask "first run" on every boot
- moby: improve gPodder launch time
- moby: replace jellyfin-desktop with jellyfin-vue?
    - allows (maybe) to cache media for offline use
    - "newer" jellyfin client
    - not packaged for nix
- moby/sxmo: display numerical vol percentage in topbar
- package Nix/NixOS docs for Zeal
    - install [doc-browser](https://github.com/qwfy/doc-browser)
    - this supports both dash (zeal) *and* the datasets from <https://devdocs.io> (which includes nix!)
    - install [devhelp](https://wiki.gnome.org/Apps/Devhelp)  (gnome)
- have xdg-open parse `<repo:...> URIs (or adjust them so that it _can_ parse)
- `sane.programs`: auto-populate defaults with everything from `pkgs`
- `sane.persist`: auto-create parent dirs in ~/private
  - currently if the application doesn't autocreate dirs leading to its destination, then ~/private storage fails
  - this might be why librewolf on mobile is still amnesiac
- sane-bt-search: show details like 5.1 vs stereo, h264 vs h265

### perf
- why does zsh take so long to init?
- why does nixos-rebuild switch take 5 minutes when net is flakey?
    - trying to auto-mount servo?
    - something to do with systemd services restarting/stalling
    - maybe wireguard & its refresh operation, specifically?
- fix OOM for large builds like webkitgtk
    - these use significant /tmp space.
    - either place /tmp on encrypted-cleared-at-boot storage
        - which probably causes each CPU load for the encryption
    - or have nix builds use a subdir of /tmp like /tmp/nix/...
        - and place that on non-encrypted clear-on-boot (with very lax writeback/swappiness to minimize writes)
    - **or set up encrypted swap**
        - encrypted swap could remove the need for my encrypted-cleared-at-boot stuff


## NEW FEATURES:
- migrate MAME cabinet to nix
    - boot it from PXE from servo?
- enable IPv6
