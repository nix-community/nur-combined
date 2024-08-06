## BUGS
- `rmDbusServices` may break sandboxing
  - e.g. if the package ships a systemd unit which references $out, then make-sandboxed won't properly update that unit.
  - `rmDbusServicesInPlace` is not affected
- when moby wlan is explicitly set down (via ip link set wlan0 down), /var/lib/trust-dns/dhcp-configs doesn't get reset
  - `ip monitor` can detect those manual link state changes (NM-dispatcher it seems cannot)
  - or try dnsmasq?
- trust-dns can't resolve `abs.twimg.com`
- trust-dns can't resolve `social.kernel.org`
- trust-dns can't resolve `pe.usps.com`
- trust-dns can't resolve `social.seattle.wa.us`
- sandbox: link cache means that if i update ~/.config/... files inline, sandboxed programs still see the old version
- mpv: continues to play past the end of some audio files
- mpv: audiocast has mpv sending its output to the builtin speakers unless manually changed
- `ssh` access doesn't grant same linux capabilities as login
- syshud (volume overlay): when casting with `blast`, syshud doesn't react to volume changes
- moby: kaslr is effectively disabled
  - `dmesg | grep "KASLR disabled due to lack of seed"`
  - fix by adding `kaslrseed` to uboot script before `booti`
    - <https://github.com/armbian/build/pull/4352>
    - not sure how that's supposed to work with tow-boot; maybe i should just update tow-boot
- moby: bpf is effectively disabled?
  - `dmesg | grep 'systemd[1]: bpf-lsm: Failed to load BPF object: No such process'`
  - `dmesg | grep 'hid_bpf: error while preloading HID BPF dispatcher: -22'`
- `s6` is not re-entrant
  - so if the desktop crashes, the login process from `unl0kr` fails to re-launch the GUI

## REFACTORING:
- add import checks to my Python nix-shell scripts
- consolidate ~/dev and ~/ref
  - ~/dev becomes a link to ~/ref/cat/mine
- fold hosts/common/home/ssh.nix -> hosts/common/users/colin.nix
- don't hardcode IP addresses so much in servo

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

#### upstreaming to non-nixpkgs repos
- gtk: build schemas even on cross compilation: <https://github.com/NixOS/nixpkgs/pull/247844>


## IMPROVEMENTS:
- kernels: ship the same kernel on every machine
  - then i can tune the kernels for hardening, without duplicating that work 4 times
- zfs: replace this with something which doesn't require a custom kernel build
- mpv: add media looping controls (e.g. loop song, loop playlist)
- curlftpfs: replace with something better
  - safer (rust? actively maintained? sandboxable?)
  - handles spaces/symbols in filenames
  - has better multi-stream perf (e.g. `sane-sync-music` should be able to copy N items in parallel)

### security/resilience
- validate duplicity backups!
- encrypt more ~ dirs (~/archives, ~/records, ..?)
  - best to do this after i know for sure i have good backups
- /mnt/desko/home, etc, shouldn't include secrets (~/private)
  - 95% of its use is for remote media access and stuff which isn't in VCS (~/records)
- port all sane.programs to be sandboxed
  - sandbox `curlftpfs`
  - sandbox `nix`
  - sandbox `sshfs-fuse`
  - sandbox mount units
    - gocryptfs: /mnt/persist/private
    - curlftpfs: /mnt/servo/*
    - sshfs: /mnt/{desko,lappy,moby}/home
  - enforce that all `environment.packages` has a sandbox profile (or explicitly opts out)
  - revisit "non-sandboxable" apps and check that i'm not actually just missing mountpoints
    - LL_FS_RW=/ isn't enough -- need all mount points like `=/:/proc:/sys:...`.
  - ensure non-bin package outputs are linked for sandboxed apps
    - i.e. `outputs.man`, `outputs.debug`, `outputs.doc`, ...
  - lock down dbus calls within the sandbox
    - otherwise anyone can `systemd-run --user ...` to potentially escape a sandbox
    - <https://github.com/flatpak/xdg-dbus-proxy>
  - port sanebox to a compiled language (hare?)
    - it adds like 50-70ms launch time _on my laptop_. i'd hate to know how much that is on the pinephone.
- make dconf stuff less monolithic
  - i.e. per-app dconf profiles for those which need it. possible static config.
  - flatpak/spectrum has some stuff to proxy dconf per-app

### user experience
- rofi: sort items case-insensitively
- replace starship prompt with something more efficient
  - watch `forkstat`: it does way too much
- cleanup waybar/nwg-panel so that it's not invoking playerctl every 2 seconds
  - nwg-panel: doesn't know that virtual-desktop 10/TV exists
- install apps:
  - display QR codes for WiFi endpoints: <https://linuxphoneapps.org/apps/noappid.wisperwind.wifi2qr/>
  - shopping list (not in nixpkgs): <https://linuxphoneapps.org/apps/ro.hume.cosmin.shoppinglist/>
  - offline Wikipedia (or, add to `wike`)
  - offline docs viewer (gtk): <https://github.com/workbenchdev/Biblioteca>
  - some type of games manager/launcher
    - Gnome Highscore (retro games)?: <https://gitlab.gnome.org/World/highscore>
  - better maps for mobile (Osmin (QtQuick)? Pure Maps (Qt/Kirigami)?)
  - note-taking app: <https://linuxphoneapps.org/categories/note-taking/>
    - Folio is nice, uses standard markdown, though it only supports flat repos
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
- sane-sync-music: remove empty dirs

#### moby
- fix cpuidle (gets better power consumption): <https://xnux.eu/log/077.html>
- fix cpupower for better power/perf
  - `journalctl -u cpupower --boot` (problem is present on lappy, at least)
- moby: tune keyboard layout
- SwayNC: add option to change audio output
- moby: tune GPS
  - fix iio-sensor-proxy magnetometer scaling
  - tune QGPS setting in eg25-control, for less jitter?
  - configure geoclue to do some smoothing?
  - manually do smoothing, as some layer between mepo and geoclue?
  - email wigle.net people to unlock API access
- moby: port `freshen-agps` timer service to s6 (maybe i want some `s6-cron` or something)
- moby: improve gPodder launch time
- moby: theme GTK apps (i.e. non-adwaita styles)
  - especially, make the menubar collapsible
  - try Gradience tool specifically for theming adwaita? <https://linuxphoneapps.org/apps/com.github.gradienceteam.gradience/>

#### non-moby
- RSS: integrate a paywall bypass
  - e.g. self-hosted [ladder](https://github.com/everywall/ladder) (like 12ft.io)
- RSS: have podcasts get downloaded straight into ~/Videos/...
  - and strip the ads out using Whisper transcription + asking a LLM where the ad breaks are
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
- transmission: apply `sane-tag-media` path fix in `torrent-done` script
  - many .mkv files do appear to be tagged: i'd just need to add support in my own tooling
- uninsane.org: make URLs relative to allow local use (and as offline homepage)
- email: fix so that local mail doesn't go to junk
  - git sendmail flow adds the DKIM signatures, but gets delivered locally w/o having the sig checked, so goes into Junk
  - could change junk filter from "no DKIM success" to explicit "DKIM failed"
  - add an auto-reply address (e.g. `reply-test@uninsane.org`) which reflects all incoming mail; use this (or a friend running this) for liveness checks

### perf
- add `pkgs.impure-cached.<foo>` package set to build things with ccache enabled
  - every package here can be auto-generated, and marked with some env var so that it doesn't pollute the pure package set
  - would be super handy for package prototyping!

## NEW FEATURES:
- migrate MAME cabinet to nix
  - boot it from PXE from servo?
- enable IPv6
