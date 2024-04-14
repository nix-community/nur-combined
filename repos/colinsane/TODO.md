## BUGS
- schlock (moby) doesn't seem to actually run
- mpv: no way to exit fullscreen video on moby
  - uosc hides controls on FS, and touch doesn't support unhiding
- i accidentally create sub-splits in sway all the time
  - especially on moby => unusable
  - like toplevel is split L/R, and then the L is a tabbed view and the R is a tabbed view
- Signal restart loop drains battery
  - decrease s6 restart time?
- sane-sysvol hangs mpv exit
- `ssh` access doesn't grant same linux capabilities as login
- ringer (i.e. dino incoming call) doesn't prevent moby from sleeping
- sway mouse/kb hotplug doesn't work
- `nix` operations from lappy hang when `desko` is unreachable
  - could at least direct the cache to `http://desko-hn:5001`

## REFACTORING:
- REMOVE DEPRECATED `crypt` from sftpgo_auth_hook
- consolidate ~/dev and ~/ref
  - ~/dev becomes a link to ~/ref/cat/mine
- fold hosts/common/home/ssh.nix -> hosts/common/users/colin.nix

### sops/secrets
- rework secrets to leverage `sane.fs`
- remove sops activation script as it's covered by my systemd sane.fs impl
- user secrets could just use `gocryptfs`, like with ~/private?
  - can gocryptfs support nested filesystems, each with different perms (for desko, moby, etc)?

### roles
- allow any host to take the role of `uninsane.org`
  - will make it easier to test new services?

### upstreaming
- add updateScripts to all my packages in nixpkgs
- REVIEW/integrate jellyfin dataDir config: <https://github.com/NixOS/nixpkgs/pull/233617>

#### upstreaming to non-nixpkgs repos
- gtk: build schemas even on cross compilation: <https://github.com/NixOS/nixpkgs/pull/247844>


## IMPROVEMENTS:
### security/resilience
- add FTPS support for WAN users of uninsane.org (and possibly require it?)
- validate duplicity backups!
- encrypt more ~ dirs (~/archives, ~/records, ..?)
  - best to do this after i know for sure i have good backups
- /mnt/desko/home, etc, shouldn't include secrets (~/private)
  - 95% of its use is for remote media access and stuff which isn't in VCS (~/records)
- port all sane.programs to be sandboxed
  - enforce that all `environment.packages` has a sandbox profile (or explicitly opts out)
  - revisit "non-sandboxable" apps and check that i'm not actually just missing mountpoints
    - LL_FS_RW=/ isn't enough -- need all mount points like `=/:/proc:/sys:...`.
  - ensure non-bin package outputs are linked for sandboxed apps
    - i.e. `outputs.man`, `outputs.debug`, `outputs.doc`, ...
  - lock down dbus calls within the sandbox
    - otherwise anyone can `systemd-run --user ...` to potentially escape a sandbox
    - <https://github.com/flatpak/xdg-dbus-proxy>
  - remove `.ssh` access from Firefox!
    - limit access to `~/knowledge/secrets` through an agent that requires GUI approval, so a firefox exploit can't steal all my logins
  - port sane-sandboxed to a compiled language (hare?)
    - it adds like 50-70ms launch time _on my laptop_. i'd hate to know how much that is on the pinephone.
  - remove /run/wrappers from the sandbox path
    - they're mostly useless when using no-new-privs, just an opportunity to forget to specify deps
- make dconf stuff less monolithic
  - i.e. per-app dconf profiles for those which need it. possible static config.
- canaries for important services
  - e.g. daily email checks; daily backup checks
  - integrate `nix check` into Gitea actions?

### user experience
- give `mpv` better `nice`ness?
- xdg-desktop-portal shouldn't kill children on exit
  - *maybe* a job for `setsid -f`?
- replace starship prompt with something more efficient
  - watch `forkstat`: it does way too much
- cleanup waybar so that it's not invoking playerctl every 2 seconds
- install apps:
  - display QR codes for WiFi endpoints: <https://linuxphoneapps.org/apps/noappid.wisperwind.wifi2qr/>
  - shopping list (not in nixpkgs): <https://linuxphoneapps.org/apps/ro.hume.cosmin.shoppinglist/>
  - offline Wikipedia (or, add to `wike`)
  - offline docs viewer (gtk): <https://github.com/workbenchdev/Biblioteca>
  - some type of games manager/launcher
    - Gnome Highscore (retro games)?: <https://gitlab.gnome.org/World/highscore>
  - better maps for mobile (Osmin (QtQuick)? Pure Maps (Qt/Kirigami)? Gnome Maps is improved in 45)
  - note-taking app: <https://linuxphoneapps.org/categories/note-taking/>
  - OSK overlay specifically for mobile gaming
    - i.e. mock joysticks, for use with SuperTux and SuperTuxKart
- install mobile-friendly games:
  - Shattered Pixel Dungeon (nixpkgs `shattered-pixel-dungeon`; doesn't cross-compile b/c openjdk/libIDL) <https://github.com/ebolalex/shattered-pixel-dungeon>
  - UnCiv (Civ V clone; nixpkgs `unciv`; doesn't cross-compile):  <https://github.com/yairm210/UnCiv>
  - Simon Tatham's Puzzle Collection (not in nixpkgs) <https://git.tartarus.org/?p=simon/puzzles.git>
  - Shootin Stars  (Godot; not in nixpkgs) <https://gitlab.com/greenbeast/shootin-stars>
  - numberlink (generic name for Flow Free). not packaged in Nix
  - Neverball (https://neverball.org/screenshots.php). nix: as `neverball`
  - blurble (https://linuxphoneapps.org/games/app.drey.blurble/). nix: not as of 2024-02-05
  - Trivia Quiz (https://linuxphoneapps.org/games/io.github.nokse22.trivia-quiz/)

#### moby
- fix cpuidle (gets better power consumption): <https://xnux.eu/log/077.html>
- moby: tune keyboard layout
- SwayNC:
  - don't show MPRIS if no players detected
    - this is a problem of playerctld, i guess
  - add option to change audio output
  - fix colors (red alert) to match overall theme
- moby: tune GPS
  - run only geoclue, and not gpsd, to save power?
  - tune QGPS setting in eg25-control, for less jitter?
  - direct mepo to prefer gpsd, with fallback to geoclue, for better accuracy?
  - configure geoclue to do some smoothing?
  - manually do smoothing, as some layer between mepo and geoclue/gpsd?
- moby: show battery state on ssh login
- moby: improve gPodder launch time
- moby: theme GTK apps (i.e. non-adwaita styles)
  - especially, make the menubar collapsible
  - try Gradience tool specifically for theming adwaita? <https://linuxphoneapps.org/apps/com.github.gradienceteam.gradience/>

#### non-moby
- RSS: integrate a paywall bypass
  - e.g. self-hosted [ladder](https://github.com/everywall/ladder) (like 12ft.io)
- neovim: set up language server (lsp; rnix-lsp; nvim-lspconfig)
- neovim: integrate LLMs
- Helix: make copy-to-system clipboard be the default
- firefox/librewolf: persist history
  - just not cookies or tabs
- package Nix/NixOS docs for Zeal
  - install [doc-browser](https://github.com/qwfy/doc-browser)
  - this supports both dash (zeal) *and* the datasets from <https://devdocs.io> (which includes nix!)
  - install [devhelp](https://wiki.gnome.org/Apps/Devhelp)  (gnome)
- have xdg-open parse `<repo:...> URIs (or adjust them so that it _can_ parse)
- sane-bt-search: show details like 5.1 vs stereo, h264 vs h265
  - maybe just color these "keywords" in all search results?
- uninsane.org: make URLs relative to allow local use (and as offline homepage)
- email: fix so that local mail doesn't go to junk
  - git sendmail flow adds the DKIM signatures, but gets delivered locally w/o having the sig checked, so goes into Junk
  - could change junk filter from "no DKIM success" to explicit "DKIM failed"

### perf
- debug nixos-rebuild times
- add `pkgs.impure-cached.<foo>` package set to build things with ccache enabled
  - every package here can be auto-generated, and marked with some env var so that it doesn't pollute the pure package set
  - would be super handy for package prototyping!

## NEW FEATURES:
- migrate MAME cabinet to nix
  - boot it from PXE from servo?
- enable IPv6
