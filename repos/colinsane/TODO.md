## BUGS
- nixpkgs date is incorrect (1970.01.01...)
- ringer (i.e. dino incoming call) doesn't prevent moby from sleeping
- `nix` operations from lappy hang when `desko` is unreachable
  - could at least direct the cache to `http://desko-hn:5001`
- entering the wrong password in unl0kr hangs the TTY

## REFACTORING:
- consolidate ~/dev and ~/ref
  - ~/dev becomes a link to ~/ref/cat/mine
- fold hosts/common/home/ssh.nix -> hosts/common/users/colin.nix

### sops/secrets
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
- REVIEW/integrate jellyfin dataDir config: <https://github.com/NixOS/nixpkgs/pull/233617>

#### upstreaming to non-nixpkgs repos
- gtk: build schemas even on cross compilation: <https://github.com/NixOS/nixpkgs/pull/247844>


## IMPROVEMENTS:
### security/resilience
- validate duplicity backups!
- encrypt more ~ dirs (~/archives, ~/records, ..?)
  - best to do this after i know for sure i have good backups
- port all sane.programs to be sandboxed
  - enforce that all `environment.packages` has a sandbox profile (or explicitly opts out)
  - integrate `xdg-open` with the sandbox profiles
    - xdg-open can run as a highly-permissioned service, fielding requests.
    - when it determines the handler, it can enforce the sandbox profile on that handler's behalf,
      ensuring that anything launched with xdg-open is lowly-permissioned.
    - then, the actual desktop can be permissioned *lower*. e.g. no access to ~/.ssh, even in nautilus.
      `xdg-open terminal` would grant a high-permission interactive terminal, for doing high-permissioned things.
    - i think there's already a xdg-open dbus equivalent in gnome. search "firejail URL issue"
    - ALTERNATIVELY:
      1. compute the closure of each program and its `suggestedPrograms`
      2. jump into a sandbox for the above
      3. launch some program which fields requests and passes them to xdg-open
      4. launch the original program we seek to sandbox in a _nested_ sandbox, of just its own files, but with xdg-open aliased to forward requests to the proxy.
      - i don't know how exactly the proxy works: `mkfifo`? a TCP socket that traverses a network namespace? there's some complexity here.
      - this is sort of just a more sophisticated version of the above.
      - computing sandbox unions is probably far more difficult than it appears. e.g. what to do when a `bwrap` program wishes to call a `landlock` program? how is that outer scope to be sandboxed? my sandboxes are already frail enough that making them dynamic like this will surely cause unpredictable breakages.
  - lock down dbus calls within the sandbox
    - otherwise anyone can `systemd-run --user ...` to potentially escape a sandbox
    - <https://github.com/flatpak/xdg-dbus-proxy>
  - remove `.ssh` access from Firefox!
    - limit access to `~/private/knowledge/secrets` through an agent that requires GUI approval, so a firefox exploit can't steal all my logins
- make dconf stuff less monolithic
  - i.e. per-app dconf profiles for those which need it. possible static config.
- canaries for important services
  - e.g. daily email checks; daily backup checks
  - integrate `nix check` into Gitea actions?

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
  - blurble (https://linuxphoneapps.org/games/app.drey.blurble/). nix: not as of 2024-02-05

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
- debug nixos-rebuild times
  - i bet sane.programs adds a LOT of time, with how it automatically creates an attrs for EVERY package in nixpkgs.
- add `pkgs.impure-cached.<foo>` package set to build things with ccache enabled
  - every package here can be auto-generated, and marked with some env var so that it doesn't pollute the pure package set
  - would be super handy for package prototyping!
- fix desko so it doesn't dispatch so many build jobs to servo by default

## NEW FEATURES:
- migrate MAME cabinet to nix
  - boot it from PXE from servo?
- enable IPv6
