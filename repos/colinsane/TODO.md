## BUGS
- why i need to manually restart `wireguard-wg-ovpns` on servo periodically
  - else DNS fails
- fix port 53 UPnP failures
- fix epiphany to launch on moby
  - something to do with bwrap/bubblewrap?

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
    - bubblewrap-based sandboxing: <https://github.com/nixpak/nixpak>
- canaries for important services
    - e.g. daily email checks; daily backup checks
    - integrate `nix check` into Gitea actions?

### user experience
- neovim: set up language server (lsp; rnix-lsp; nvim-lspconfig)
- Helix: make copy-to-system clipboard be the default
- Sway: use <Super> instead of <Alt>, so that <Alt> can be used by applications
- firefox/librewolf: don't show browserpass/sponsorblock/metamask "first run" on every boot
- firefox/librewolf: persist history
  - just not cookies or tabs
- moby: improve gPodder launch time
- moby: theme GTK apps (i.e. non-adwaita styles)
  - especially, make the menubar collapsible
  - try Gradience tool specifically for theming adwaita? <https://linuxphoneapps.org/apps/com.github.gradienceteam.gradience/>
- moby: ship camera app (megapixels)
  - may need to enable firmware in hosts/by-name/moby/default.nix
- package Nix/NixOS docs for Zeal
    - install [doc-browser](https://github.com/qwfy/doc-browser)
    - this supports both dash (zeal) *and* the datasets from <https://devdocs.io> (which includes nix!)
    - install [devhelp](https://wiki.gnome.org/Apps/Devhelp)  (gnome)
- have xdg-open parse `<repo:...> URIs (or adjust them so that it _can_ parse)
- sane-bt-search: show details like 5.1 vs stereo, h264 vs h265
- uninsane.org: make URLs relative to allow local use (and as offline homepage)
- email: fix so that local mail doesn't go to junk
  - git sendmail flow adds the DKIM signatures, but gets delivered locally w/o having the sig checked, so goes into Junk
  - could change junk filter from "no DKIM success" to explicit "DKIM failed"

### perf
- why does zsh take so long to init?
    - try using Starship prompt instead? <https://starship.rs/>
      - supports git-status stuff too
      - can probably displace all of the powerlevel10k stuff
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
- get moby to build without binfmt emulation (i.e. make all emulation explicit)
  - then i can distribute builds across servo + desko, and also allow servo to pull packages from desko w/o worrying about purity


## NEW FEATURES:
- migrate MAME cabinet to nix
    - boot it from PXE from servo?
- enable IPv6
