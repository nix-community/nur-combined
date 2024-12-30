## BUGS
- dissent has a memory leak (3G+ after 24hr)
  - set a max memory use in the systemd service, to force it to restart as it leaks?
- `rmDbusServices` may break sandboxing
  - e.g. if the package ships a systemd unit which references $out, then make-sandboxed won't properly update that unit.
  - `rmDbusServicesInPlace` is not affected
- mpv: audiocast has mpv sending its output to the builtin speakers unless manually changed
- syshud (volume overlay): when casting with `blast`, syshud doesn't react to volume changes
- dissent: if i launch it without net connectivity, it gets stuck at the login, and never tries again
- newsflash on moby can't play videos
  - "open in browser" works though -- in mpv
- gnome-maps can't use geoclue *and* openstreetmap at the same time
  - get gnome-maps to speak xdg-desktop-portal, and this will be fixed
- epiphany can't save cookies
  - see under "preferences", cookies are disabled
  - prevents logging into websites (OpenStreetMap)
  - works when sandbox is disabled
- rsync to ssh target fails because of restrictive sandboxing
- `/mnt/.servo_ftp` retries every 10s, endlessly, rather than doing a linear backoff
  - repro by `systemctl stop sftpgo` on servo, then watching `mnt-.servo_ftp.{mount,timer}` on desko

## REFACTORING:
- fold hosts/modules/ into toplevel modules/
- add import checks to my Python nix-shell scripts
- consolidate ~/dev and ~/ref
  - ~/dev becomes a link to ~/ref/cat/mine
- fold hosts/common/home/ssh.nix -> hosts/common/users/colin.nix
- don't hardcode IP addresses so much in servo

### sops/secrets
- user secrets could just use `gocryptfs`, like with ~/private?
  - can gocryptfs support nested filesystems, each with different perms (for desko, moby, etc)?

### upstreaming
- upstream blueprint-compiler cross fixes -> nixpkgs
- upstream cargo cross fixes -> nixpkgs
- upstream `gps-share` package -> nixpkgs

#### upstreaming to non-nixpkgs repos
- gnome-calls: retry net connection when DNS is down
- gtk: build schemas even on cross compilation: <https://github.com/NixOS/nixpkgs/pull/247844>
- linux: upstream PinePhonePro device trees
- nwg-panel: configurable media controls
- nwg-panel / playerctl hang fix (i think nwg-panel is what should be patched here)


## IMPROVEMENTS:
- sane-deadlines: show day of the week for upcoming items
- curlftpfs: replace with something better
  - safer (rust? actively maintained? sandboxable?)
  - handles spaces/symbols in filenames
  - has better multi-stream perf (e.g. `sane-sync-music` should be able to copy N items in parallel)
- firefox: open *all* links (http, https, ...) with system handler
  - removes the need for open-in-mpv, firefox-xdg-open, etc.
  - matrix room links *just work*.
  - `network.protocol-handler.external.https = true` in about:config *seems* to do this,
    but breaks some webpages (e.g. Pleroma)
- associate http(s)://*.pdf with my pdf handler
  - can't do that because lots of applications don't handle URIs
  - could workaround using a wrapper that downloads the file and then passes it to the program
- geary: replace with envelope
  - likely requires updating envelope to a more recent version (for multi-accounting), and therefore updating libadwaita...

### security/resilience
- enable `snapper` btrfs snapshots (`services.snapper`)
- /mnt/desko/home, etc, shouldn't include secrets (~/private)
  - 95% of its use is for remote media access and stuff which isn't in VCS (~/records)
- harden systemd services:
  - servo: `coturn.service`
  - servo: `postgresql.service`
  - servo: `postfix.service`
  - servo: `prosody.service`
  - servo: `slskd.service`
  - desko: `usbmuxd.service`
  - servo: `backup-torrents.service`
  - servo: `dedupe-media.service`
  - remove SGID /run/wrappers/bin/sendmail, and just add senders to `postdrop` group
- port all sane.programs to be sandboxed
  - sandbox `nix`
  - enforce that all `environment.packages` has a sandbox profile (or explicitly opts out)
  - lock down dbus calls within the sandbox
    - <https://github.com/flatpak/xdg-dbus-proxy>
    - stuff on dbus presents too much surface area
      - ~~for example anyone can `systemd-run --user ...` to potentially escape a sandbox~~
      - for example, xdg-desktop-portal allows anyone to make arbitrary DNS requests
        - e.g. `gdbus call --session --timeout 10 --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.NetworkMonitor.CanReach 'data1.exfiltrate.uninsane.org' 80`
- make gnome-keyring-daemon less monolithic
  - no reason every application with _a_ secret needs to see _all_ secrets
  - check out oo7-daemon?
  - also unix-pass based provider: <https://github.com/mdellweg/pass_secret_service>
- make dconf stuff less monolithic
  - i.e. per-app dconf profiles for those which need it. possible static config.
  - flatpak/spectrum has some stuff to proxy dconf per-app

### user experience
- setup a real calendar system, for recurring events
- rofi: sort items case-insensitively
- rofi: enable mouse mode?
- mpv: add media looping controls (e.g. loop song, loop playlist)
- mpv: add/implement an extension to search youtube
  - apparently `yt-dlp` does searching!
- replace starship prompt with something more efficient
  - watch `forkstat`: it does way too much
- cleanup nwg-panel so that it's not invoking swaync every second
  - nwg-panel: doesn't know that virtual-desktop 10/TV exists
- install apps:
  - display QR codes for WiFi endpoints: <https://linuxphoneapps.org/apps/noappid.wisperwind.wifi2qr/>
  - shopping list (not in nixpkgs): <https://linuxphoneapps.org/apps/ro.hume.cosmin.shoppinglist/>
  - offline Wikipedia (or, add to `wike`)
  - some type of games manager/launcher
    - Gnome Highscore (retro games)?: <https://gitlab.gnome.org/World/highscore>
  - better maps for mobile (Osmin (QtQuick)? Pure Maps (Qt/Kirigami)?)
  - note-taking app: <https://linuxphoneapps.org/categories/note-taking/>
    - Folio is nice, uses standard markdown, though it only supports flat repos
  - OSK overlay specifically for mobile gaming
    - i.e. mock joysticks, for use with SuperTux and SuperTuxKart
  - game: Hedgewars
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
- moby: port battery support to something upstreamable
- moby: install transito/mobroute public transit app: <https://sr.ht/~mil/mobroute/> <https://git.sr.ht/~mil/transito>
  - see: <https://github.com/NixOS/nixpkgs/pull/335613>
- moby: consider honeybee instead of gnome-calls for calling? <https://git.sr.ht/~anjan/honeybee>
  - uses XMPP, so more NAT/WoWLAN-friendly
- fix cpuidle (gets better power consumption): <https://xnux.eu/log/077.html>
- fix cpupower for better power/perf
  - `journalctl -u cpupower --boot` (problem is present on lappy, at least)
- use dynamic DRAM clocking to reduce power by 0.5W: <https://xnux.eu/log/083.html>
  - coreboot implements DRAM training for rk3399: <https://gitlab.com/vicencb/kevinboot/-/blob/master/cb/sdram.c>
- moby: tune keyboard layout
- SwayNC/nwg-panel: add option to change audio output
- Newsflash: sync OPML on start, same way i do with gpodder
- better podcasting client?

#### non-moby
- RSS: integrate a paywall bypass
  - e.g. self-hosted [ladder](https://github.com/everywall/ladder) (like 12ft.io)
- RSS: have podcasts get downloaded straight into ~/Videos/...
  - and strip the ads out using Whisper transcription + asking a LLM where the ad breaks are
- neovim: integrate ollama
- neovim: better docsets (e.g. c++, glib)
- firefox: persist history
  - just not cookies or tabs
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

## NEW FEATURES:
- migrate Kodi box to nix
- migrate MAME cabinet to nix
  - boot it from PXE from servo?
- enable IPv6
