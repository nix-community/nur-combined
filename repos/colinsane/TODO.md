## BUGS
- alacritty Ctrl+N frequently fails to `cd` to the previous directory
- bunpen dbus sandboxing can't be *nested* (likely a problem in xdg-dbus-proxy)
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
- `ovpns` (and presumably `doof`) net namespaces aren't firewalled
  - not great because things like `bitmagnet` expose unprotected admin APIs by default!

## REFACTORING:
- fold hosts/modules/ into toplevel modules/
- consolidate ~/dev and ~/ref
  - ~/dev becomes a link to ~/ref/cat/mine
- fold hosts/common/home/ssh.nix -> hosts/common/users/colin.nix
- don't hardcode IP addresses so much in servo
- modules/netns: migrate `sane.netns.$NS.services = [ FOO ]` option to be `systemd.services.$FOO.sane.netns = NS`
  - then change the ExecStartPre check to not ping `ipinfo.net` or whatever.
    either port all of `sane-ip-check` to use a self-hosted reflector,
    or settle for something like `test -eq "$(ip route get ...)" "$expectedGateway"`

### sops/secrets
- user secrets could just use `gocryptfs`, like with ~/private?
  - can gocryptfs support nested filesystems, each with different perms (for desko, moby, etc)?
- consider `agefs` (FUSE) instead of `sops` => activation scripts no longer required
  - <https://discourse.nixos.org/t/agefs-agenix-as-a-fuse-filesystem/70576>

### upstreaming
- upstream blueprint-compiler cross fixes -> nixpkgs
- upstream cargo cross fixes -> nixpkgs
- upstream `gps-share` package -> nixpkgs

#### upstreaming to non-nixpkgs repos
- gnome-calls: retry net connection when DNS is down
- gtk: build schemas even on cross compilation: <https://github.com/NixOS/nixpkgs/pull/247844>
- linux: upstream PinePhonePro device trees
  - especially the rt5640 profiles, and in a way which doesn't require alsa-ucm (see my notes in pkgs.pine64-alsa-ucm)
- nwg-panel: configurable media controls
- nwg-panel / playerctl hang fix (i think nwg-panel is what should be patched here)


## IMPROVEMENTS:
- sane-deadlines: show day of the week for upcoming items
  - and only show on "first" terminal opened; not on Ctrl+N terminals
- curlftpfs: replace with something better
  - safer (rust? actively maintained? sandboxable?)
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
- gnome calls: implement dialpad for SIP accounts (DTMF): <https://gitlab.gnome.org/GNOME/calls/-/issues/715>
- use `pkgsStatic` or `pkgsCross.musl64` where applicable, for much improved perf?

### security/resilience
- /mnt/desko/home, etc, shouldn't include secrets (~/private)
  - 95% of its use is for remote media access and stuff which isn't in VCS (~/records)
- harden systemd services:
  - all: `pcscd.service`
  - servo: `coturn.service`
  - servo: `postgresql.service`
  - servo: `postfix.service`
  - servo: `prosody.service`
  - desko: `usbmuxd.service`
  - servo: `backup-torrents.service`
  - servo: `dedupe-media.service`
  - remove SGID /run/wrappers/bin/sendmail, and just add senders to `postdrop` group
- port all sane.programs to be sandboxed
  - sandbox `nix`
  - enforce that all `environment.packages` has a sandbox profile (or explicitly opts out)
  - enforce granular dbus sandboxing (bunpen-dbus-*)
- make gnome-keyring-daemon less monolithic
  - no reason every application with _a_ secret needs to see _all_ secrets
  - check out oo7-daemon?
  - also unix-pass based provider: <https://github.com/mdellweg/pass_secret_service>
- make dconf stuff less monolithic
  - i.e. per-app dconf profiles for those which need it. possible static config.
  - flatpak/spectrum has some stuff to proxy dconf per-app
- rework `programs` API to be just an overlay which wraps each binary in an env with XDG_DATA_DIRS etc set & the config/state links placed in /nix/store instead of $HOME.
  - see: <https://github.com/Lassulus/wrappers>

### user experience
- setup a real calendar system, for recurring events
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
    - geopjr's Archive: <https://flathub.org/en/apps/dev.geopjr.Archives>. nix: not as of 2025-12-02
  - some type of games manager/launcher
    - Gnome Highscore (retro games)?: <https://gitlab.gnome.org/World/highscore>
  - LLM/AI tools:
    - Gai: <https://github.com/huanguan1978/pygai>. image gen. nixpkgs: not as of 2025-10-05
  - internet radio
    - shortwave: <https://flathub.org/en/apps/de.haeckerfelix.Shortwave>. nixpkgs: yes
  - better mobile browser
    - Kumo: <https://github.com/catacombing/kumo>. wayland -- not even gtk. nixpkgs: not as of 2025-10-05
  - better screenshot editor
    - Gradia: <https://flathub.org/en/apps/be.alexandervanhee.gradia>. nixpkgs: yes
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
  - Karambola (from Holy Pangolin, but freeware -- source not available?): <https://flathub.org/en/apps/com.agatanawrot.karambola>
  - Ultimate Tic Tac Toe: <https://flathub.org/en/apps/io.github.nokse22.ultimate-tic-tac-toe>. nix: not as of 2025-10-05
  - Flood It: <https://flathub.org/en/apps/io.github.tfuxu.floodit>. nix: not as of 2025-10-05
- sane-sync-music: remove empty dirs
- soulseek: install a CLI app usable over ssh
- moby: replace `spot` with its replacement, `riff` (<https://github.com/Diegovsky/riff>)

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
- hardware upgrade (OnePlus)?

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
- sane-bt-search: show seeder/leecher count for bitmagnet results
- transmission: apply `sane-tag-media` path fix in `torrent-done` script
  - many .mkv files do appear to be tagged: i'd just need to add support in my own tooling
  - more aggressively cleanup non-media files after DL (ripper logos, info txts)
- uninsane.org: make URLs relative to allow local use (and as offline homepage)
- waka.laka.osaka: overlay a "muted" icon when muted
- email: fix so that local mail doesn't go to junk
  - git sendmail flow adds the DKIM signatures, but gets delivered locally w/o having the sig checked, so goes into Junk
  - could change junk filter from "no DKIM success" to explicit "DKIM failed"
  - add an auto-reply address (e.g. `reply-test@uninsane.org`) which reflects all incoming mail; use this (or a friend running this) for liveness checks

## NEW FEATURES:
- migrate MAME cabinet to nix
- dedicated nix itgmania machine
- enable IPv6
