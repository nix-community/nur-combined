## BUGS
- nixpkgs date is incorrect (1970.01.01...)
- ringer (i.e. dino incoming call) doesn't prevent moby from sleeping
- `nix` operations from lappy hang when `desko` is unreachable
  - could at least direct the cache to `http://desko-hn:5001`

## REFACTORING:

- fold hosts/common/home/ssh.nix -> hosts/common/users/colin.nix

### sops/secrets
- attach secrets to the thing they're used by (sane.programs)
- rework secrets to leverage `sane.fs`
- remove sops activation script as it's covered by my systemd sane.fs impl

### roles
- allow any host to take the role of `uninsane.org`
  - will make it easier to test new services?

### upstreaming
- split out a sxmo module usable by NUR consumers
- bump nodejs version in lemmy-ui
- add updateScripts to all my packages in nixpkgs
- fix lightdm-mobile-greeter for newer libhandy
- port zecwallet-lite to a from-source build
- REVIEW/integrate jellyfin dataDir config: <https://github.com/NixOS/nixpkgs/pull/233617>

#### upstreaming to non-nixpkgs repos
- gtk: build schemas even on cross compilation: <https://github.com/NixOS/nixpkgs/pull/247844>


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

### faster/better deployments
- remove audacity's dependency on webkitgtk (via wxwidgets)

### user experience
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

#### moby
- fix cpuidle (gets better power consumption): <https://xnux.eu/log/077.html>
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
- phog: remove the gnome-shell runtime dependency to save hella closure size

#### non-moby
- RSS: integrate a paywall bypass
  - e.g. self-hosted [ladder](https://github.com/everywall/ladder) (like 12ft.io)
- neovim: set up language server (lsp; rnix-lsp; nvim-lspconfig)
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
- add `pkgs.impure-cached.<foo>` package set to build things with ccache enabled
  - every package here can be auto-generated, and marked with some env var so that it doesn't pollute the pure package set
  - would be super handy for package prototyping!
- fix desko so it doesn't dispatch so many build jobs to servo by default

## NEW FEATURES:
- migrate MAME cabinet to nix
  - boot it from PXE from servo?
- enable IPv6
- package lemonade lemmy app: <https://linuxphoneapps.org/apps/ml.mdwalters.lemonade/>
