# Lan Tian's NUR Packages

![Build and populate cache](https://github.com/xddxdd/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fxddxdd%2Fnur-packages)](https://garnix.io)

## Warning

This NUR contains packages customized for my own use. These packages reside categories starting with `lantian`. I do not ensure that they stay backwards compatible or functionally stable, nor do I accept any requests to tailor them for public use.

Packages in all other categories are for public use. I will try my best to minimize changes/customizations on them, and accept issues and pull requests for them.

## How to use

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Add packages from this repo
        inputs.nur-xddxdd.nixosModules.setupOverlay

        # Setup QEMU userspace emulation that works with Docker
        inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt

        # Binary cache (optional, choose any one, or see guide below)
        inputs.nur-xddxdd.nixosModules.nix-cache-attic
        inputs.nur-xddxdd.nixosModules.nix-cache-garnix
      ];
    };
  };
}
```

## Binary Cache

This NUR automatically builds and pushes build artifacts to several binary caches. You can use any one of them to speed up your build.

### Self-hosted (Attic)

```nix
{
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
}
```

Or, use variables from this repository in case I change them:

```nix
{
  nix.settings.substituters = [ nur.repos.xddxdd._meta.atticUrl ];
  nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.atticPublicKey ];
}
```

### Garnix.io

```nix
{
  nix.settings.substituters = [ "https://cache.garnix.io" ];
  nix.settings.trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
}
```

Or, use variables from this repository in case I change them:

```nix
{
  nix.settings.substituters = [ nur.repos.xddxdd._meta.garnixUrl ];
  nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.garnixPublicKey ];
}
```

## Packages

<details>
<summary>Package set: (Uncategorized) (194 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `acpi-ec` | [acpi-ec](https://github.com/musikid/acpi_ec) | 1.0.4 | Kernel module to access directly to the ACPI EC |
| `x86_64-linux` | `adspower` | [adspower](https://www.adspower.com/) | 7.3.26 | Antidetect Browser for Multi-Accounts |
|  | `amule-dlp` | [amule-dlp](https://github.com/persmule/amule-dlp) | 2.3.2-unstable-2023-03-02 | Peer-to-peer client for the eD2K and Kademlia networks (with Dynamic Leech Protection) |
|  | `asterisk-g72x` | [asterisk-g72x](https://github.com/arkadijs/asterisk-g72x) | 0-unstable-2025-09-01 | G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled) |
|  | `axiom-syslog-proxy` | [axiom-syslog-proxy](https://github.com/axiomhq/axiom-syslog-proxy) | 0.8.0 | Syslog push interface to Axiom |
| `x86_64-linux` | `baidunetdisk` | [baidunetdisk](https://pan.baidu.com/) | 4.17.7 | Baidu Netdisk |
|  | `baidupcs-go` | [baidupcs-go](https://github.com/qjfoidnh/BaiduPCS-Go) | 4.0.0-unstable-2025-10-29 | Baidu Netdisk commandline client, mimicking Linux shell file handling commands |
|  | `bepasty` | [bepasty](https://bepasty-server.readthedocs.org/) | 1.2.2 | Universal pastebin server |
|  | `bilibili` | [bilibili](https://app.bilibili.com/) | 1.17.2-2 | Desktop client for Bilibili |
|  | `bin-cpuflags-x86` | [bin-cpuflags-x86](https://github.com/HanabishiRecca/bin-cpuflags-x86) | 1.0.3 | Small CLI tool to detect CPU flags (instruction sets) of X86 binaries |
|  | `bird-lg-go` | [bird-lg-go](https://github.com/xddxdd/bird-lg-go) | 1.3.12.1 | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
|  | `bird-lgproxy-go` | [bird-lgproxy-go](https://github.com/xddxdd/bird-lg-go) | 1.3.12.1 | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
|  | `bnxtnvm` | [bnxtnvm](https://resource.fs.com/mall/resource/broadcom-ethernet-network-adapter-user-manual.pdf) | 222.0.144.0 | Broadcom BNXTNVM utility |
|  | `boringssl-oqs` | [boringssl-oqs](https://openquantumsafe.org) | 0-unstable-2025-08-31 | Fork of BoringSSL that includes prototype quantum-resistant key exchange and authentication in the TLS handshake based on liboqs |
|  | `browser360` | [browser360](https://browser.360.net/gc/index.html) | 13.4.1000.77 | Browser from 360 |
|  | `calibre-cops` | [calibre-cops](http://blog.slucas.fr/en/oss/calibre-opds-php-server) | 3.7.8 | Web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks |
|  | `click-loglevel` | [click-loglevel](https://github.com/jwodder/click-loglevel) | 0.7.0 | Log level parameter type for Click |
|  | `cockpy` | [cockpy](https://github.com/Hiro420/CockPY) | 0-unstable-2024-09-07 | Public and open source version of the cbt2 ps im working on |
|  | `comp128` | [comp128](https://github.com/Takuto88/comp128-python) | 1.0.0 | Python implementation of the Comp128 v1-3 GSM authentication algorithms |
|  | `cryptodev-unstable` | [cryptodev-linux](http://cryptodev-linux.org/) | 1.14-unstable-2025-11-03 | Device that allows access to Linux kernel cryptographic drivers |
| `x86_64-linux` | `crystalhd` | [crystalhd](https://github.com/dbason/crystalhd) | 0-unstable-2021-01-26 | Broadcom Crystal HD Hardware Decoder (BCM70012/70015) driver |
|  | `data-recorder` | [data-recorder](https://github.com/g1879/DataRecorder) | 3.6.2 | Python-based toolkit to record data into files |
|  | `dbip-lite` | [dbip-lite](https://db-ip.com/db/lite.php) | 2025-11 | DBIP's Lite GeoIP Country, City, and ASN databases |
|  | `decluttarr` | [decluttarr](https://github.com/ManiMatter/decluttarr) | 1.50.2 | Watches radarr, sonarr, lidarr and readarr download queues and removes downloads if they become stalled or no longer needed |
|  | `deeplx` | [deeplx](https://deeplx.owo.network) | 1.1.0 | Powerful Free DeepL API, No Token Required |
| `x86_64-linux` | `dingtalk` | [dingtalk](https://www.dingtalk.com/) | 7.6.45.5041701 | Enterprise communication and collaboration platform developed by Alibaba Group |
|  | `dn42-pingfinder` | [dn42-pingfinder](https://git.dn42.dev/dn42/pingfinder/src/branch/master/clients) | 1.2.1-unstable-2022-11-06 | DN42 Pingfinder |
|  | `download-kit` | [download-kit](https://github.com/g1879/DownloadKit) | 2.0.7 | Simple to use multi-threaded download toolkit |
|  | `dpdk-kmod` | [dpdk-kmod](https://git.dpdk.org/dpdk-kmods/) | 0-unstable-2024-11-20 | DPDK kernel modules or add-ons |
|  | `drission-page` | [drission-page](https://github.com/g1879/DrissionPage) | 4.1.1.2 | Python based web automation tool |
|  | `drone-file-secret` | [drone-file-secret](https://github.com/xddxdd/drone-file-secret) | 0-unstable-2023-06-25 | Secret provider for Drone CI that reads secrets from a given folder |
|  | `drone-vault` | [drone-vault](https://docs.drone.io/configure/secrets/external/vault/) | 1.3.0 | Drone plugin for integrating with the Vault secrets manager |
|  | `dump978` | [dump978](https://github.com/flightaware/dump978) | 10.2 | FlightAware's 978MHz UAT demodulator |
|  | `edge-tts` | [edge-tts](https://github.com/rany2/edge-tts) | 7.2.3 | Use Microsoft Edge's online text-to-speech service from Python WITHOUT needing Microsoft Edge or Windows or an API key |
|  | `electron_11` | [electron](https://github.com/electron/electron) | 11.5.0 | Cross platform desktop application shell |
|  | `etherguard` | [etherguard](https://github.com/KusakabeShi/EtherGuard-VPN) | 0.3.5-f5 | Layer 2 version of WireGuard with Floyd Warshall implementation in Go |
|  | `fake-ollama` | [fake-ollama](https://github.com/spoonnotfound/fake-ollama) | 0-unstable-2025-02-14 | Simulated server implementation of Ollama API |
|  | `fastapi-dls` | [fastapi-dls](https://gitea.publichub.eu/oscar.krause/fastapi-dls) | 2.0.1-unstable-2025-05-13 | Minimal Delegated License Service (DLS) |
|  | `fcitx5-breeze` | [fcitx5-breeze](https://github.com/scratch-er/fcitx5-breeze) | 3.1.0 | Fcitx5 theme to match KDE's Breeze style |
|  | `flapalerted` | [flapalerted](https://github.com/Kioubit/FlapAlerted) | 3.14.3 | BGP Update based flap detection |
|  | `flaresolverr-21hsmw` | [flaresolverr-21hsmw](https://github.com/21hsmw/FlareSolverr) | 0-unstable-2025-03-04 | Proxy server to bypass Cloudflare protection, with 21hsmw modifications to support nodriver |
|  | `flaresolverr-alexfozor` | [flaresolverr-alexfozor](https://github.com/AlexFozor/FlareSolverr) | 0-unstable-2024-08-04 | Proxy server to bypass Cloudflare protection, with AlexFozor modifications to support Drission Page |
|  | `fr24feed` | [fr24feed](https://www.flightradar24.com/share-your-data) | 1.0.54-0 | Flightradar24 Decoder & Feeder lets you effortlessly share ADS-B data with Flightradar24 |
|  | `ftp-proxy` | [ftp-proxy](http://www.ftpproxy.org/) | 1.2.3 | FTP Proxy Server |
|  | `funasr` | [funasr](https://www.funasr.com/) | 0-unstable-2025-10-01 | Fundamental End-to-End Speech Recognition Toolkit and Open Source SOTA Pretrained Models |
|  | `geolite2` | [geolite2](https://dev.maxmind.com/geoip/geoip2/geolite2/) | 2025.11.04 | MaxMind's GeoIP2 GeoLite2 Country, City, and ASN databases |
|  | `glauth` | [glauth](https://github.com/glauth/glauth) | 2.4.0 | Lightweight LDAP server for development, home use, or CI |
| `x86_64-linux` | `google-earth-pro` | [google-earth-pro](https://www.google.com/earth/) | 7.3.6.10441 | World sphere viewer |
|  | `gopherus` | [gopherus](http://gopherus.sourceforge.net/) | 1.2.2 | Free, multiplatform, console-mode gopher client that provides a classic text interface to the gopherspace |
|  | `gost-engine` | [gost-engine](https://github.com/gost-engine/engine) | 3.0.3 | Reference implementation of the Russian GOST crypto algorithms for OpenSSL |
|  | `grasscutter` | [grasscutter](https://github.com/Grasscutters/Grasscutter) | 1.7.4 | Server software reimplementation for a certain anime game |
| `x86_64-linux` | `gst-plugin-crystalhd` | [gst-plugin-crystalhd](https://launchpad.net/ubuntu/+source/crystalhd) | 0-unstable-2020-03-22 | Broadcom Crystal HD Hardware Decoder (BCM70012/70015) GStreamer plugin |
|  | `gwmp-mux` | [gwmp-mux](https://github.com/helium/gwmp-mux) | 0.11.0 | Multiplexer for Semtech's GWMP over UDP |
|  | `hack3ric-flow` | [hack3ric-flow](https://github.com/hack3ric/flow) | 0.2.0-unstable-2025-09-28 | BGP flowspec executor |
|  | `hath` | [hath](https://e-hentai.org/) | 1.6.2 | Hentai@Home |
|  | `helium-gateway-rs` | [helium-gateway-rs](https://github.com/helium/gateway-rs) | 1.3.0-unstable-2025-04-11 | Helium Gateway |
|  | `hesuvi-hrir` | [hesuvi-hrir](https://sourceforge.net/projects/hesuvi/) | 2.0.0.1 | Headphone Surround Virtualizations for Equalizer APO |
|  | `hi3-ii-martian-font` | [hi3-ii-martian-font](https://github.com/Wenti-D/HI3IIMartianFont) | 0-unstable-2023-10-12 | Font for Martian in Honkai Impact 3rd |
|  | `hoyo-glyphs` | [hoyo-glyphs](https://github.com/SpeedyOrc-C/Hoyo-Glyphs) | 20250529 | Constructed scripts by Hoyoverse 米哈游的架空文字 |
| `x86_64-linux` | `i915-sriov` | [i915-sriov](https://github.com/strongtz/i915-sriov-dkms) | 0-unstable-2025-11-04 | DKMS module of Linux i915 driver with SR-IOV support |
|  | `igsc` | [igsc](https://github.com/intel/igsc) | 1.0.0 | Intel graphics system controller firmware update library |
|  | `imewlconverter` | [imewlconverter](https://github.com/studyzy/imewlconverter) | 3.2.0 | FOSS program for converting IME dictionaries |
|  | `jproxy` | [jproxy](https://github.com/LuckyPuppy514/jproxy) | 3.4.1 | Proxy between Sonarr / Radarr and Jackett / Prowlarr, mainly used to optimize search and improve recognition rate |
|  | `kaixinsong-fonts` | [kaixinsong-fonts](http://www.guoxuedashi.net/zidian/bujian/KaiXinSong.php) | 3.0 | KaiXinSong |
|  | `kaldiio` | [kaldiio](https://github.com/nttcslab-sp/kaldiio) | 2.18.1 | Pure python module for reading and writing kaldi ark files |
|  | `kikoplay` | [kikoplay](https://kikoplay.fun) | 2.0.0 | More than a Full-Featured Danmu Player |
|  | `konnect` | [konnect](https://github.com/Kopano-dev/konnect) | 0.34.0 | Kopano Konnect implements an OpenID provider (OP) with integrated web login and consent forms |
|  | `ldap-auth-proxy` | [ldap-auth-proxy](https://github.com/pinepain/ldap-auth-proxy) | 0.2.0-unstable-2020-07-29 | Simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend |
| `x86_64-linux` | `libcrystalhd` | [libcrystalhd](https://launchpad.net/ubuntu/+source/crystalhd) | 0-unstable-2021-01-26 | Broadcom Crystal HD Hardware Decoder (BCM70012/70015) userspace library |
|  | `libnftnl-fullcone` | [libnftnl](https://netfilter.org/projects/libnftnl/) | 1.3.0 | Userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem |
|  | `liboqs` | [liboqs](https://openquantumsafe.org) | 0.14.0 | C library for prototyping and experimenting with quantum-resistant cryptography |
|  | `liboqs-unstable` | [liboqs](https://openquantumsafe.org) | 0-unstable-2025-11-04 | C library for prototyping and experimenting with quantum-resistant cryptography |
| `x86_64-linux` | `libqcef` | [libqcef](https://github.com/martyr-deepin/libqcef) | 0-unstable-2019-11-23 | Qt5 binding of CEF |
| `x86_64-linux` | `linguaspark-server` | [linguaspark-server](https://github.com/LinguaSpark/server) | 0-unstable-2025-10-12 | Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs |
| `x86_64-linux` | `linguaspark-server-x86-64-v3` | [linguaspark-server](https://github.com/LinguaSpark/server) | 0-unstable-2025-10-12 | Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs |
|  | `loralib` | [loralib](https://arxiv.org/abs/2106.09685) | 0-unstable-2024-12-16 | Implementation of "LoRA: Low-Rank Adaptation of Large Language Models" |
|  | `lyrica` | [lyrica](https://github.com/chiyuki0325/lyrica) | 0.14-1 | Linux desktop lyrics widget focused on simplicity and integration |
|  | `lyrica-plasmoid` | [lyrica](https://github.com/chiyuki0325/lyrica) | 0.14-1 | Linux desktop lyrics widget focused on simplicity and integration (Plasmoid component) |
|  | `magiskboot` | [magiskboot](https://topjohnwu.github.io/Magisk/tools.html) | 29.0 | Tool to unpack / repack boot images, parse / patch / extract cpio, patch dtb, hex patch binaries, and compress / decompress files with multiple algorithms |
|  | `mautrix-gmessages` | [mautrix-gmessages](https://github.com/mautrix/gmessages) | 0.2510.0 | Matrix-Google Messages puppeting bridge |
|  | `metee` | [metee](https://github.com/intel/metee) | 6.0.2 | C library to access CSE/CSME/GSC firmware via a MEI interface |
|  | `modelscope` | [modelscope](https://www.modelscope.cn/) | 1.31.0 | Bring the notion of Model-as-a-Service to life |
|  | `mtkclient` | [mtkclient](https://github.com/bkerler/mtkclient) | 2.0.1.freeze | MTK reverse engineering and flash tool |
| `x86_64-linux` | `mtranservercore-rs` | [linguaspark-server](https://github.com/LinguaSpark/server) | 0-unstable-2025-10-12 | Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs |
|  | `ncmdump-rs` | [ncmdump-rs](https://github.com/iqiziqi/ncmdump.rs) | 0.8.0 | NetEase Cloud Music copyright protection file dump by rust |
|  | `netboot-xyz` | [netboot-xyz](https://netboot.xyz/) | 2.0.88 | Network-based bootable operating system installer based on iPXE |
| `x86_64-linux` | `netease-cloud-music` | [netease-cloud-music](https://music.163.com) | 1.2.1 | NetEase Cloud Music Linux Client (package script adapted from NixOS-CN and Freed-Wu) |
|  | `netns-exec` | [netns-exec](https://github.com/pekman/netns-exec) | 0-unstable-2016-07-30 | Run command in Linux network namespace as normal user |
|  | `nft-fullcone` | [nft-fullcone](https://github.com/fullcone-nat-nftables/nft-fullcone) | 0-unstable-2023-05-17 | Nftables fullcone expression kernel module |
|  | `nftables-fullcone` | [nftables](https://netfilter.org/projects/nftables/) | 1.1.5 | Project that aims to replace the existing {ip,ip6,arp,eb}tables framework |
|  | `noise-suppression-for-voice` | [noise-suppression-for-voice](https://github.com/werman/noise-suppression-for-voice) | 1.10 | Noise suppression plugin based on Xiph's RNNoise |
|  | `nullfs` | [nullfs](https://github.com/xrgtn/nullfs) | 0-unstable-2016-01-28 | FUSE nullfs drivers |
|  | `nullfsvfs` | [nullfsvfs](https://github.com/abbbi/nullfsvfs) | 0.21 | Virtual black hole file system that behaves like /dev/null |
|  | `nvlax` | [nvlax](https://github.com/illnyang/nvlax) | unstable-2021-10-29 | Future-proof NvENC & NvFBC patcher |
|  | `nvlax-530` | [nvlax](https://github.com/illnyang/nvlax) | unstable-2021-10-29 | Future-proof NvENC & NvFBC patcher (for NVIDIA driver >= 530) |
|  | `oci-arm-host-capacity` | [oci-arm-host-capacity](https://github.com/hitrov/oci-arm-host-capacity) | 0-unstable-2024-08-13 | This script allows to bypass Oracle Cloud Infrastructure 'Out of host capacity' error immediately when additional OCI capacity will appear in your Home Region / Availability domain |
|  | `one-api` | [one-api](https://openai.justsong.cn) | 0.6.10 | OpenAI key management & redistribution system, using a single API for all LLMs |
|  | `open-webui-kb-manager` | [open-webui-kb-manager](https://github.com/dubh3124/OpenWebUI-KB-Manager) | 0.2.0 | Command-line interface (CLI) tool for managing files and knowledge bases in OpenWebUI |
|  | `openai-edge-tts` | [openai-edge-tts](https://tts.travisvn.com/) | 0-unstable-2025-07-01 | Text-to-speech API endpoint compatible with OpenAI's TTS API endpoint, using Microsoft Edge TTS to generate speech for free locally |
|  | `opencc-python-reimplemented` | [opencc-python-reimplemented](https://github.com/yichen0831/opencc-python) | 0-unstable-2023-02-11 | OpenCC made with Python |
|  | `openedai-speech` | [openedai-speech](https://github.com/matatonic/openedai-speech) | 0.18.2 | OpenAI API compatible text to speech server using Coqui AI's xtts_v2 and/or piper tts as the backend |
|  | `openssl-ech` | [openssl-ech](https://github.com/sftcd/openssl/tree/ECH-draft-13c) | 0-unstable-2025-05-30 | OpenSSL with Encrypted Client Hello support |
|  | `openssl-oqs-provider` | [openssl-oqs-provider](https://openquantumsafe.org) | 0.10.0 | OpenSSL 3 provider containing post-quantum algorithms |
|  | `openvswitch-dpdk` | [openvswitch-dpdk](https://www.openvswitch.org/) | 3.6.0 | Multilayer virtual switch |
|  | `ormsgpack` | [ormsgpack](https://github.com/aviramha/ormsgpack) | 1.12.0 | Msgpack serialization/deserialization library for Python, written in Rust using PyO3 and rust-msgpack |
|  | `osdlyrics` | [osdlyrics](https://github.com/osdlyrics/osdlyrics) | 0.5.15 | Standalone lyrics fetcher/displayer (windowed and OSD mode) |
|  | `palworld-exporter` | [palworld-exporter](https://github.com/palworldlol/palworld-exporter) | 1.3.1 | Prometheus exporter for Palword Server |
|  | `palworld-worldoptions` | [palworld-worldoptions](https://github.com/legoduded/palworld-worldoptions) | 1.11.0 | Tool for managing Palworld dedicated server settings |
|  | `peerbanhelper` | [peerbanhelper](https://github.com/Ghost-chu/PeerBanHelper) | 9.0.10 | Automatically bans unwanted, leeching, and anomalous BT clients, with support for custom rules for qBittorrent and Transmission |
|  | `phpmyadmin` | [phpmyadmin](https://www.phpmyadmin.net/) | 5.2.3 | Web interface for MySQL and MariaDB |
|  | `phppgadmin` | [phppgadmin](https://github.com/phppgadmin/phppgadmin) | 7.14.7-mod | Premier web-based administration tool for PostgreSQL |
|  | `plangothic-fonts` | [plangothic-fonts](https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project) | 2.9.5787 | Plangothic Project |
|  | `plasma-panel-transparency-toggle` | [plasma-panel-transparency-toggle](https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6) | 0-unstable-2024-04-17 | Rewrite of Panel Transparency Button for Plasma 6 |
|  | `plasma-smart-video-wallpaper-reborn` | [plasma-smart-video-wallpaper-reborn](https://store.kde.org/p/2139746) | 2.4.0 | Plasma 6 wallpaper plugin to play videos on your Desktop/Lock Screen |
|  | `plasma-yesplaymusic-lyric` | [plasma-yesplaymusic-lyric](https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics) | 0.2.3-unstable-2025-01-07 | Display YesPlayMusic lyrics on the plasma panel | 在KDE plasma面板中显示YesPlayMusic的歌词 |
|  | `pterodactyl-wings` | [pterodactyl-wings](https://pterodactyl.io) | 1.11.13-unstable-2025-11-01 | Server control plane for Pterodactyl Panel |
|  | `py-rcon` | [py-rcon](https://github.com/ttk1/py-rcon) | 1.3.0 | Python implementation of RCON |
|  | `pyhss` | [pyhss](https://github.com/nickvsnetworking/pyhss) | 1.0.2-unstable-2025-04-03 | Python HSS / Diameter Server |
|  | `pyosmocom` | [pyosmocom](https://gitea.osmocom.org/osmocom/pyosmocom) | 0-unstable-2025-10-23 | Python implementation of key Osmocom protocols/interfaces |
|  | `pysctp` | [pysctp](https://github.com/p1sec/pysctp) | 0.7.2 | SCTP stack for Python |
|  | `pytorch-wpe` | [pytorch-wpe](https://github.com/nttcslab-sp/dnn_wpe) | 0.0.1 | WPE implementation using PyTorch |
|  | `qemu-user-static` | [qemu-user-static](http://www.qemu.org/) | 10.1.2+ds-2 | Generic and open source machine emulator and virtualizer |
|  | `qq` | [qq](https://im.qq.com/linuxqq/index.html) | 3.2.18 | Desktop client for QQ on Linux |
| `x86_64-linux` | `qqmusic` | [qqmusic](https://y.qq.com/) | 1.1.8 | Tencent QQ Music |
|  | `qqsp` | [qqsp](https://github.com/Sonnix1/Qqsp) | 1.9 | QT Quest Soft Player is a interactive fiction stories and games player (compatible fork of qsp.su) |
|  | `qsp` | [qsp](https://github.com/QSPFoundation/qspgui) | 5.9.4-b1-unstable-2025-10-21 | Interactive Fiction development platform (GUI application) |
|  | `qsp-lib` | [qsp-lib](https://github.com/QSPFoundation/qsp) | 0-unstable-2025-11-04 | Interactive fiction development platform (Game Library) |
|  | `r8125` | [r8125](https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software) | 9.016.01-1 | Linux device driver for Realtek 2.5/5 Gigabit Ethernet controllers with PCI-Express interface |
|  | `r8168` | [r8168](https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software) | 8.055.00 | Linux device driver for Realtek Ethernet controllers |
| `x86_64-linux` | `red-star-os-rgjanggi` | [red-star-os-rgjanggi](https://archive.org/details/RedStarOS) | 3.0 | Rgjanggi game from DPRK Red Star OS 3.0, heavily sandboxed, use at your own risk |
|  | `red-star-os-wallpapers` | [red-star-os-wallpapers](https://archive.org/details/RedStarOS) | 3.0 | Wallpapers from DPRK Red Star OS 3.0 |
|  | `rime-aurora-pinyin` | [rime-aurora-pinyin](https://github.com/hosxy/rime-aurora-pinyin) | 0-unstable-2022-08-28 | 【极光拼音】输入方案 |
|  | `rime-custom-pinyin-dictionary` | [rime-custom-pinyin-dictionary](https://github.com/wuhgit/CustomPinyinDictionary) | 20250101 | 自建拼音输入法词库，百万常用词汇量，适配 Fcitx5 (Linux / Android) 及 Gboard (Android + Magisk or KernelSU) 。 |
|  | `rime-dict` | [rime-dict](https://github.com/Iorest/rime-dict) | 0-unstable-2020-12-26 | RIME 词库增强 |
|  | `rime-ice` | [rime-ice](https://dvel.me/posts/rime-ice/) | 0-unstable-2025-11-04 | Rime 配置：雾凇拼音 | 长期维护的简体词库 |
|  | `rime-moegirl` | [rime-moegirl](https://github.com/outloudvi/mw2fcitx/releases) | 20251009 | RIME dictionary file for entries from zh.moegirl.org.cn |
|  | `rime-zhwiki` | [rime-zhwiki](https://github.com/felixonmars/fcitx5-pinyin-zhwiki) | 20250823 | RIME dictionary file for entries from zh.wikipedia.org |
|  | `rootutils` | [rootutils](https://pypi.org/project/rootutils/) | 1.0.7 | Simple python package to solve all your problems with pythonpath, work dir, file paths, module imports and environment variables |
|  | `route-chain` | [route-chain](https://github.com/xddxdd/route-chain) | 0-unstable-2023-09-09 | Small app to generate a long path in traceroute |
|  | `rtpengine` | [rtpengine](https://github.com/sipwise/rtpengine) | mr13.3.1.4 | Sipwise media proxy for Kamailio |
|  | `runpod-python` | [runpod-python](https://github.com/runpod/runpod-python) | 1.7.13 | Python library for RunPod API and serverless worker SDK |
|  | `runpodctl` | [runpodctl](https://www.runpod.io) | 1.14.11 | RunPod CLI for pod management |
|  | `sam-toki-mouse-cursors` | [sam-toki-mouse-cursors](https://github.com/SamToki/Sam-Toki-Mouse-Cursors) | 9.04 | Original mouse cursors (pointers) for Windows, with minimalistic design |
| `x86_64-linux` | `sgx-software-enable` | [sgx-software-enable](https://github.com/intel/sgx-software-enable) | 1.0-unstable-2023-01-06 | Application to enable Intel SGX on Linux systems |
|  | `sidestore-vpn` | [sidestore-vpn](https://github.com/xddxdd/sidestore-vpn) | 0-unstable-2025-06-27 | Allow SideStore to work across all iOS devices on your local network |
|  | `silero-vad` | [silero-vad](https://github.com/snakers4/silero-vad) | 6.1 | Pre-trained enterprise-grade Voice Activity Detector |
|  | `smartrent_py` | [smartrent_py](https://github.com/ZacheryThomas/smartrent.py) | 0.5.2 | Api for SmartRent locks, thermostats, moisture sensors and switches |
|  | `smfc` | [smfc](https://github.com/petersulyok/smfc) | 4.2.1 | Super Micro Fan Control |
|  | `space-cadet-pinball-full-tilt` | [SpaceCadetPinball](https://github.com/k4zmu2a/SpaceCadetPinball) | 2.1.0 | Reverse engineering of 3D Pinball for Windows – Space Cadet, a game bundled with Windows (With Full Tilt Pinball data) |
|  | `suwayomi-server` | [suwayomi-server](https://github.com/Suwayomi/Suwayomi-Server) | 2.1.1867 | Rewrite of Tachiyomi for the Desktop |
| `x86_64-linux` | `svp` | [svp](https://www.svp-team.com/wiki/SVP:Linux) | 4.6.263 | SmoothVideo Project 4 (SVP4) converts any video to 60 fps (and even higher) and performs this in real time right in your favorite video player |
|  | `svp-mpv` | [mpv-with-scripts-0.40.0](https://mpv.io) |  | General-purpose media player, fork of MPlayer and mplayer2 |
|  | `sx1302-hal` | [sx1302-hal](https://github.com/NebraLtd/sx1302_hal) | 2.1.0-unstable-2023-02-06 | SX1302/SX1303 Hardware Abstraction Layer and tools |
|  | `torch-complex` | [torch-complex](https://pypi.org/project/torch-complex) | 0.4.4 | Temporal python class for PyTorch-ComplexTensor |
|  | `tqdm-loggable` | [tqdm-loggable](https://pypi.org/project/tqdm-loggable/) | 0-unstable-2024-10-10 | TQDM progress bar helpers for logging and other headless application |
|  | `uesave` | [uesave](https://github.com/trumank/uesave-rs) | 0.6.2 | Library for reading and writing Unreal Engine save files (commonly referred to as GVAS) |
|  | `uesave-0_3_0` | [uesave](https://github.com/trumank/uesave-rs) | 0.3.0 | Library for reading and writing Unreal Engine save files (commonly referred to as GVAS), older version that works with Palworld |
|  | `uni-api` | [uni-api](https://github.com/yym68686/uni-api) | 0-unstable-2025-11-04 | Unifies the management of LLM APIs across multiple backend services |
| `x86_64-linux` | `unigine-heaven` | [unigine-heaven](https://benchmark.unigine.com/heaven) | 4.0 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-sanctuary` | [unigine-sanctuary](https://benchmark.unigine.com/sanctuary) | 2.3 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-superposition` | [unigine-superposition](https://benchmark.unigine.com/superposition) | 1.1 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-tropics` | [unigine-tropics](https://benchmark.unigine.com/tropics) | 1.3 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-valley` | [unigine-valley](https://benchmark.unigine.com/valley) | 1.0 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
|  | `usque` | [usque](https://github.com/Diniboy1123/usque) | 1.4.2 | Open-source reimplementation of the Cloudflare WARP client's MASQUE protocol |
|  | `vbmeta-disable-verification` | [vbmeta-disable-verification](https://github.com/libxzr/vbmeta-disable-verification) | 1.0 | Patch Android vbmeta image and disable verification flags inside |
|  | `vector-quantize-pytorch` | [vector-quantize-pytorch](https://github.com/lucidrains/vector-quantize-pytorch) | 1.24.2 | Vector (and Scalar) Quantization, in Pytorch |
|  | `vgpu-unlock-rs` | [vgpu-unlock-rs](https://github.com/mbilker/vgpu_unlock-rs) | 2.5.0 | Unlock vGPU functionality for consumer grade GPUs |
|  | `vk-hdr-layer` | [vk-hdr-layer](https://github.com/Zamundaaa/VK_hdr_layer) | 0-unstable-2025-07-31 | Vulkan layer utilizing a small color management / HDR protocol for experimentation |
|  | `vlmcsd` | [vlmcsd](https://github.com/Wind4/vlmcsd) | 1113-unstable-2023-07-28 | KMS Emulator in C |
|  | `vpp` | [vpp](https://wiki.fd.io/view/VPP/What_is_VPP%3F) | 25.10 | Vector Packet Processing |
|  | `vuetorrent-backend` | [vuetorrent-backend](https://github.com/VueTorrent/vuetorrent-backend) | 2.7.0 | FSimple backend service to store configuration server-side |
|  | `wechat-uos-sandboxed` | [wechat-uos](https://weixin.qq.com/) | 4.0.1.12 | WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `x86_64-linux` | `wine-wechat` | [wine-wechat](https://weixin.qq.com/) | 3.9.12.57 | Wine WeChat x64 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat) |
| `x86_64-linux` | `wine-wechat-x86` | [wine-wechat-x86](https://weixin.qq.com/) | 3.9.12.56 | Wine WeChat x86 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat) |
|  | `xstatic-asciinema-player` | [xstatic-asciinema-player](https://github.com/asciinema/asciinema-player) | 2.6.1.1 | Asciinema-player packaged for setuptools (easy_install) / pip |
|  | `xstatic-font-awesome` | [xstatic-font-awesome](https://github.com/FortAwesome/Font-Awesome) | 4.7.0.0 | Font Awesome packaged for setuptools (easy_install) / pip |
|  | `xt_rtpengine` | [xt_rtpengine](https://github.com/sipwise/rtpengine) | mr13.3.1.4 | Sipwise media proxy for Kamailio (kernel module) |
|  | `xue` | [xue](https://pypi.org/project/xue/) | 0.0.34 | Minimalist web front-end framework composed of HTMX and Python |
|  | `xvcd` | [xvcd](https://github.com/RHSResearchLLC/xvcd) | 0-unstable-2019-11-20 | Xilinx Virtual Cable Daemon |
| `Broken` | `ast` | [ast](https://www.aspeedtech.com/support_driver/) | 1.15.1_4 | Aspeed Graphics Driver |
| `Broken` | `coqui-tts` | [coqui-tts](http://coqui.ai) | 0.22.0 | Deep learning toolkit for Text-to-Speech, battle-tested in research and production |
| `Broken` | `douban-openapi-server` | [douban-openapi-server](https://github.com/caryyu/douban-openapi-server) | 0-unstable-2022-12-17 | Douban API server that provides an unofficial APIs for media information gathering |
| `Broken` | `fish-speech` | [fish-speech](https://speech.fish.audio/) | 1.5.1 | SOTA Open Source TTS |
| `Deprecated` `x86_64-linux` | `inter-knot` | [inter-knot](https://inot.top) | 2.16.9+36 | (DEPRECATED: Service has ceased operation) 绳网是一个游戏、技术交流平台 |
| `Deprecated` | `kata-image` | [kata-image](https://github.com/kata-containers/kata-containers) | 3.22.0 | (DEPRECATED: kata-image is available in nixpkgs by a different maintainer) Open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs (Packaging script adapted from https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-images/default.nix) |
| `Deprecated` | `kata-runtime` | [kata-runtime](https://github.com/kata-containers/kata-containers) | 3.22.0 | (DEPRECATED: kata-runtime is available in nixpkgs by a different maintainer) Open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs (Packaging script adapted from https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-runtime/default.nix) |
| `Broken` | `kui` | [kui](https://kui.aber.sh/) | 1.14.0 | Easy-to-use web framework |
| `Deprecated` | `payload-dumper-go` | [payload-dumper-go](https://github.com/ssut/payload-dumper-go) | 1.3.0 | (DEPRECATED: payload-dumper-go is available in nixpkgs by a different maintainer) Android OTA payload dumper written in Go |
| `Deprecated` `x86_64-linux` | `pocl` | [pocl](http://portablecl.org) | 7.1 | (DEPRECATED: pocl is available in nixpkgs) Portable OpenCL standard implementation |
| `Broken` | `soggy` | [soggy](https://github.com/LDAsuku/soggy) | 0-unstable-2022-12-14 | Experimental server emulator for a game I forgot its name |
| `Broken` | `uksmd` | [uksmd](https://github.com/CachyOS/uksmd) | 1.3.0 | Userspace KSM helper daemon |
| `Deprecated` `x86_64-linux` | `wechat-uos` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | (DEPRECATED: wechat-uos is available in nixpkgs, if you still want sandbox functionality, use wechat-uos-sandboxed package.) WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `Deprecated` `x86_64-linux` | `wechat-uos-bin` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | (DEPRECATED: wechat-uos is available in nixpkgs, if you still want sandbox functionality, use wechat-uos-sandboxed package.) WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `Deprecated` `x86_64-linux` | `wechat-uos-without-sandbox` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | (DEPRECATED: wechat-uos is available in nixpkgs, if you still want sandbox functionality, use wechat-uos-sandboxed package.) WeChat desktop without sandbox (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
</details>


<details>
<summary>Package set: asteriskDigiumCodecs (75 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `asteriskDigiumCodecs.10.g729a` | [asterisk-10-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.5 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.10.silk` | [asterisk-10-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.0 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.10.siren14` | [asterisk-10-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.10.siren7` | [asterisk-10-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.g729a` | [asterisk-11-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.silk` | [asterisk-11-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.siren14` | [asterisk-11-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.siren7` | [asterisk-11-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.g729a` | [asterisk-12-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.7 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.silk` | [asterisk-12-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.siren14` | [asterisk-12-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.siren7` | [asterisk-12-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.g729a` | [asterisk-13-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.opus` | [asterisk-13-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.silk` | [asterisk-13-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.siren14` | [asterisk-13-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.siren7` | [asterisk-13-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.g729a` | [asterisk-14-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.opus` | [asterisk-14-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.silk` | [asterisk-14-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.siren14` | [asterisk-14-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.siren7` | [asterisk-14-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.g729a` | [asterisk-15-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.opus` | [asterisk-15-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.silk` | [asterisk-15-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.siren14` | [asterisk-15-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.siren7` | [asterisk-15-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.g729a` | [asterisk-16-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.opus` | [asterisk-16-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.silk` | [asterisk-16-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.siren14` | [asterisk-16-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.siren7` | [asterisk-16-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.g729a` | [asterisk-17-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.opus` | [asterisk-17-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.silk` | [asterisk-17-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.siren14` | [asterisk-17-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.siren7` | [asterisk-17-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.g729a` | [asterisk-18-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.opus` | [asterisk-18-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.silk` | [asterisk-18-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.siren14` | [asterisk-18-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.siren7` | [asterisk-18-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.g729a` | [asterisk-19-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.opus` | [asterisk-19-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.silk` | [asterisk-19-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.siren14` | [asterisk-19-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.siren7` | [asterisk-19-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_4.g729a` | [asterisk-1.4-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.5 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_6_2_0.g729a` | [asterisk-1.6.2.0-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.5 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_6_2_0.siren14` | [asterisk-1.6.2.0-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_6_2_0.siren7` | [asterisk-1.6.2.0-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_0.g729a` | [asterisk-1.8.0-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.6 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_0.siren14` | [asterisk-1.8.0-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_0.siren7` | [asterisk-1.8.0-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_4.g729a` | [asterisk-1.8.4-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.8 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.g729a` | [asterisk-20-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.opus` | [asterisk-20-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.silk` | [asterisk-20-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.siren14` | [asterisk-20-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.siren7` | [asterisk-20-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.g729a` | [asterisk-21-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.opus` | [asterisk-21-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.silk` | [asterisk-21-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.siren14` | [asterisk-21-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.siren7` | [asterisk-21-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.g729a` | [asterisk-22-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.opus` | [asterisk-22-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.silk` | [asterisk-22-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.siren14` | [asterisk-22-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.siren7` | [asterisk-22-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.23.g729a` | [asterisk-23-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.23.opus` | [asterisk-23-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.23.silk` | [asterisk-23-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.23.siren14` | [asterisk-23-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.23.siren7` | [asterisk-23-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk siren7 Codec by Digium |
</details>

<details>
<summary>Package set: deprecated (8 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `deprecated.inter-knot` | [inter-knot](https://inot.top) | 2.16.9+36 | (DEPRECATED: Service has ceased operation) 绳网是一个游戏、技术交流平台 |
|  | `deprecated.kata-image` | [kata-image](https://github.com/kata-containers/kata-containers) | 3.22.0 | (DEPRECATED: kata-image is available in nixpkgs by a different maintainer) Open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs (Packaging script adapted from https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-images/default.nix) |
|  | `deprecated.kata-runtime` | [kata-runtime](https://github.com/kata-containers/kata-containers) | 3.22.0 | (DEPRECATED: kata-runtime is available in nixpkgs by a different maintainer) Open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs (Packaging script adapted from https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-runtime/default.nix) |
|  | `deprecated.payload-dumper-go` | [payload-dumper-go](https://github.com/ssut/payload-dumper-go) | 1.3.0 | (DEPRECATED: payload-dumper-go is available in nixpkgs by a different maintainer) Android OTA payload dumper written in Go |
| `x86_64-linux` | `deprecated.pocl` | [pocl](http://portablecl.org) | 7.1 | (DEPRECATED: pocl is available in nixpkgs) Portable OpenCL standard implementation |
| `x86_64-linux` | `deprecated.wechat-uos` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | (DEPRECATED: wechat-uos is available in nixpkgs, if you still want sandbox functionality, use wechat-uos-sandboxed package.) WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `x86_64-linux` | `deprecated.wechat-uos-bin` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | (DEPRECATED: wechat-uos is available in nixpkgs, if you still want sandbox functionality, use wechat-uos-sandboxed package.) WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `x86_64-linux` | `deprecated.wechat-uos-without-sandbox` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | (DEPRECATED: wechat-uos is available in nixpkgs, if you still want sandbox functionality, use wechat-uos-sandboxed package.) WeChat desktop without sandbox (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
</details>

<details>
<summary>Package set: kernel-modules (11 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `kernel-modules.acpi-ec` | [acpi-ec](https://github.com/musikid/acpi_ec) | 1.0.4 | Kernel module to access directly to the ACPI EC |
|  | `kernel-modules.cryptodev-unstable` | [cryptodev-linux](http://cryptodev-linux.org/) | 1.14-unstable-2025-11-03 | Device that allows access to Linux kernel cryptographic drivers |
| `x86_64-linux` | `kernel-modules.crystalhd` | [crystalhd](https://github.com/dbason/crystalhd) | 0-unstable-2021-01-26 | Broadcom Crystal HD Hardware Decoder (BCM70012/70015) driver |
|  | `kernel-modules.dpdk-kmod` | [dpdk-kmod](https://git.dpdk.org/dpdk-kmods/) | 0-unstable-2024-11-20 | DPDK kernel modules or add-ons |
| `x86_64-linux` | `kernel-modules.i915-sriov` | [i915-sriov](https://github.com/strongtz/i915-sriov-dkms) | 0-unstable-2025-11-04 | DKMS module of Linux i915 driver with SR-IOV support |
|  | `kernel-modules.nft-fullcone` | [nft-fullcone](https://github.com/fullcone-nat-nftables/nft-fullcone) | 0-unstable-2023-05-17 | Nftables fullcone expression kernel module |
|  | `kernel-modules.nullfsvfs` | [nullfsvfs](https://github.com/abbbi/nullfsvfs) | 0.21 | Virtual black hole file system that behaves like /dev/null |
|  | `kernel-modules.r8125` | [r8125](https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software) | 9.016.01-1 | Linux device driver for Realtek 2.5/5 Gigabit Ethernet controllers with PCI-Express interface |
|  | `kernel-modules.r8168` | [r8168](https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software) | 8.055.00 | Linux device driver for Realtek Ethernet controllers |
|  | `kernel-modules.xt_rtpengine` | [xt_rtpengine](https://github.com/sipwise/rtpengine) | mr13.3.1.4 | Sipwise media proxy for Kamailio (kernel module) |
| `Broken` | `kernel-modules.ast` | [ast](https://www.aspeedtech.com/support_driver/) | 1.15.1_4 | Aspeed Graphics Driver |
</details>

<details>
<summary>Package set: lantianCustomized (15 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `lantianCustomized.asterisk` | [asterisk](https://www.asterisk.org/) | 20.16.0 | Asterisk with Lan Tian modifications |
|  | `lantianCustomized.attic-telnyx-compatible` | [attic](https://github.com/zhaofengli/attic) | 0-unstable-2025-09-24 | Multi-tenant Nix Binary Cache |
|  | `lantianCustomized.coredns` | [coredns](https://github.com/xddxdd/coredns) | 1.12.2 | CoreDNS with Lan Tian's modifications |
|  | `lantianCustomized.ffmpeg` | [ffmpeg](https://www.ffmpeg.org/) | 7.1.1 | FFmpeg with Lan Tian modifications |
|  | `lantianCustomized.firefox-icon-mikozilla-fireyae` | [firefox-icon-mikozilla-fireyae](https://www.reddit.com/r/Genshin_Impact/comments/x73g4p/mikozilla_fireyae/) |  | Custom icon "Mikozilla Fireyae" for Firefox |
|  | `lantianCustomized.librime-with-plugins` | [librime](https://rime.im/) | 1.14.0 | Librime with plugins (librime-charcode, librime-lua, librime-octagram, librime-proto) |
|  | `lantianCustomized.llama-cpp` | [llama-cpp](https://github.com/ggml-org/llama.cpp) | 6953 | Inference of Meta's LLaMA model (and others) in pure C/C++ |
|  | `lantianCustomized.ls-iommu` | [ls-iommu](https://gist.github.com/r15ch13/ba2d738985fce8990a4e9f32d07c6ada) | 1.0 | List IOMMUs on system |
|  | `lantianCustomized.materialgram` | [materialgram](https://kukuruzka165.github.io/materialgram/) | 6.2.3.1 | Telegram Desktop fork with material icons and some improvements (Without anti-features) |
|  | `lantianCustomized.nbfc-linux` | [nbfc-linux-lantian](https://github.com/xddxdd/nbfc-linux) | 0-unstable-2022-06-13 | NoteBook FanControl ported to Linux (with Lan Tian's modifications) |
|  | `lantianCustomized.nginx` | [nginx-lantian](https://openresty.org) | 1.27.1.2 | OpenResty with Lan Tian modifications |
|  | `lantianCustomized.nixos-cleanup` | [nixos-cleanup](https://github.com/xddxdd/nur-packages) | 1.0 | Cleanup old profiles on NixOS |
|  | `lantianCustomized.telegram-desktop` | [telegram-desktop](https://desktop.telegram.org/) | 6.2.3 | Telegram Desktop messaging app (Without anti-features) |
|  | `lantianCustomized.transmission-with-webui` | [transmission](https://www.transmissionbt.com/) | 4.0.6 | Fast, easy and free BitTorrent client |
|  | `lantianCustomized.x86-arch-level` | [x86-arch-level](https://unix.stackexchange.com/a/631226) | 1.0 | Check x86 architecture level |
</details>

<details>
<summary>Package set: lantianLinuxCachyOS (8 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `lantianLinuxCachyOS.lts` | [linux-cachyos-lts](https://www.kernel.org/) | 6.12.57 | Linux CachyOS Kernel with Lan Tian Modifications |
|  | `lantianLinuxCachyOS.lts-configfile` | linux-config | 6.12.57 |  |
|  | `lantianLinuxCachyOS.lts-lto` | [linux-cachyos-lts-lto](https://www.kernel.org/) | 6.12.57 | Linux CachyOS Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxCachyOS.lts-lto-configfile` | linux-config | 6.12.57 |  |
|  | `lantianLinuxCachyOS.v6_12` | [linux-cachyos-v6_12](https://www.kernel.org/) | 6.12.57 | Linux CachyOS Kernel with Lan Tian Modifications |
|  | `lantianLinuxCachyOS.v6_12-configfile` | linux-config | 6.12.57 |  |
|  | `lantianLinuxCachyOS.v6_12-lto` | [linux-cachyos-v6_12-lto](https://www.kernel.org/) | 6.12.57 | Linux CachyOS Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxCachyOS.v6_12-lto-configfile` | linux-config | 6.12.57 |  |
</details>

<details>
<summary>Package set: lantianLinuxCachyOSPackages (0 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |

</details>

<details>
<summary>Package set: lantianLinuxXanmod (68 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `lantianLinuxXanmod.lts-generic` | [linux-xanmod-lts-generic](https://www.kernel.org/) | 6.12.57-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.lts-generic-configfile` | linux-config | 6.12.57-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-generic-lto` | [linux-xanmod-lts-generic-lto](https://www.kernel.org/) | 6.12.57-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.lts-generic-lto-configfile` | linux-config | 6.12.57-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-generic` | [linux-xanmod-v6_0-generic](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-generic-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-generic-lto` | [linux-xanmod-v6_0-generic-lto](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-generic-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1` | [linux-xanmod-v6_0-x86_64-v1](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1-lto` | [linux-xanmod-v6_0-x86_64-v1-lto](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2` | [linux-xanmod-v6_0-x86_64-v2](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2-lto` | [linux-xanmod-v6_0-x86_64-v2-lto](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3` | [linux-xanmod-v6_0-x86_64-v3](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3-lto` | [linux-xanmod-v6_0-x86_64-v3-lto](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4` | [linux-xanmod-v6_0-x86_64-v4](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4-lto` | [linux-xanmod-v6_0-x86_64-v4-lto](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-generic` | [linux-xanmod-v6_1-generic](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-generic-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-generic-lto` | [linux-xanmod-v6_1-generic-lto](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-generic-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1` | [linux-xanmod-v6_1-x86_64-v1](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1-lto` | [linux-xanmod-v6_1-x86_64-v1-lto](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2` | [linux-xanmod-v6_1-x86_64-v2](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2-lto` | [linux-xanmod-v6_1-x86_64-v2-lto](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3` | [linux-xanmod-v6_1-x86_64-v3](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3-lto` | [linux-xanmod-v6_1-x86_64-v3-lto](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4` | [linux-xanmod-v6_1-x86_64-v4](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4-lto` | [linux-xanmod-v6_1-x86_64-v4-lto](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_12-generic` | [linux-xanmod-v6_12-generic](https://www.kernel.org/) | 6.12.57-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_12-generic-configfile` | linux-config | 6.12.57-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_12-generic-lto` | [linux-xanmod-v6_12-generic-lto](https://www.kernel.org/) | 6.12.57-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_12-generic-lto-configfile` | linux-config | 6.12.57-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-generic` | [linux-xanmod-v6_6-generic](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-generic-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-generic-lto` | [linux-xanmod-v6_6-generic-lto](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-generic-lto-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1` | [linux-xanmod-v6_6-x86_64-v1](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1-lto` | [linux-xanmod-v6_6-x86_64-v1-lto](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1-lto-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2` | [linux-xanmod-v6_6-x86_64-v2](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2-lto` | [linux-xanmod-v6_6-x86_64-v2-lto](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2-lto-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3` | [linux-xanmod-v6_6-x86_64-v3](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3-lto` | [linux-xanmod-v6_6-x86_64-v3-lto](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3-lto-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4` | [linux-xanmod-v6_6-x86_64-v4](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4-configfile` | linux-config | 6.6.72-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4-lto` | [linux-xanmod-v6_6-x86_64-v4-lto](https://www.kernel.org/) | 6.6.72-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4-lto-configfile` | linux-config | 6.6.72-xanmod1 |  |
</details>

<details>
<summary>Package set: lantianLinuxXanmodPackages (0 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |

</details>

<details>
<summary>Package set: nvidia-grid (196 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `nvidia-grid.grid.11_8` | [nvidia-x11-450.191.01-6.12.57](https://www.nvidia.com/object/unix.html) | 450.191.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.12_4` | [nvidia-x11-460.106.00-6.12.57](https://www.nvidia.com/object/unix.html) | 460.106.00 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_0` | [nvidia-x11-470.63.01-6.12.57](https://www.nvidia.com/object/unix.html) | 470.63.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_12` | [nvidia-x11-470.256.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_3` | [nvidia-x11-470.129.06-6.12.57](https://www.nvidia.com/object/unix.html) | 470.129.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_4` | [nvidia-x11-470.141.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.141.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_5` | [nvidia-x11-470.161.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_6` | [nvidia-x11-470.161.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_7` | [nvidia-x11-470.182.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.182.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_9` | [nvidia-x11-470.223.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_0` | [nvidia-x11-510.47.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_1` | [nvidia-x11-510.73.08-6.12.57](https://www.nvidia.com/object/unix.html) | 510.73.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_2` | [nvidia-x11-510.85.02-6.12.57](https://www.nvidia.com/object/unix.html) | 510.85.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_3` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_4` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_0` | [nvidia-x11-525.60.13-6.12.57](https://www.nvidia.com/object/unix.html) | 525.60.13 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_1` | [nvidia-x11-525.85.05-6.12.57](https://www.nvidia.com/object/unix.html) | 525.85.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_2` | [nvidia-x11-525.105.17-6.12.57](https://www.nvidia.com/object/unix.html) | 525.105.17 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_3` | [nvidia-x11-525.125.06-6.12.57](https://www.nvidia.com/object/unix.html) | 525.125.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_0` | [nvidia-x11-535.54.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.54.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_1` | [nvidia-x11-535.104.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.104.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_10` | [nvidia-x11-535.247.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.247.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_11` | [nvidia-x11-535.261.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.261.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_12` | [nvidia-x11-535.274.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.274.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_2` | [nvidia-x11-535.129.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_3` | [nvidia-x11-535.154.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.154.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_4` | [nvidia-x11-535.161.07-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_5` | [nvidia-x11-535.161.08-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_6` | [nvidia-x11-535.183.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_7` | [nvidia-x11-535.183.06-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_8` | [nvidia-x11-535.216.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.216.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_9` | [nvidia-x11-535.230.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.230.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_0` | [nvidia-x11-550.54.14-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.14 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_1` | [nvidia-x11-550.54.15-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.15 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_2` | [nvidia-x11-550.90.07-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_3` | [nvidia-x11-550.90.07-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_4` | [nvidia-x11-550.127.05-6.12.57](https://www.nvidia.com/object/unix.html) | 550.127.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_5` | [nvidia-x11-550.144.03-6.12.57](https://www.nvidia.com/object/unix.html) | 550.144.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_6` | [nvidia-x11-550.163.01-6.12.57](https://www.nvidia.com/object/unix.html) | 550.163.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.18_0` | [nvidia-x11-570.124.06-6.12.57](https://www.nvidia.com/object/unix.html) | 570.124.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.18_1` | [nvidia-x11-570.133.20-6.12.57](https://www.nvidia.com/object/unix.html) | 570.133.20 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.18_2` | [nvidia-x11-570.148.08-6.12.57](https://www.nvidia.com/object/unix.html) | 570.148.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.18_3` | [nvidia-x11-570.158.01-6.12.57](https://www.nvidia.com/object/unix.html) | 570.158.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.18_4` | [nvidia-x11-570.172.08-6.12.57](https://www.nvidia.com/object/unix.html) | 570.172.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.18_5` | [nvidia-x11-570.195.03-6.12.57](https://www.nvidia.com/object/unix.html) | 570.195.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.19_0` | [nvidia-x11-580.65.06-6.12.57](https://www.nvidia.com/object/unix.html) | 580.65.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.19_1` | [nvidia-x11-580.82.07-6.12.57](https://www.nvidia.com/object/unix.html) | 580.82.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.19_2` | [nvidia-x11-580.95.05-6.12.57](https://www.nvidia.com/object/unix.html) | 580.95.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.9_2` | [nvidia-x11-430.63-6.12.57](https://www.nvidia.com/object/unix.html) | 430.63 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.11_8` | [nvidia-x11-450.191.01-6.12.57](https://www.nvidia.com/object/unix.html) | 450.191.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.12_4` | [nvidia-x11-460.106.00-6.12.57](https://www.nvidia.com/object/unix.html) | 460.106.00 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_0` | [nvidia-x11-470.63.01-6.12.57](https://www.nvidia.com/object/unix.html) | 470.63.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_12` | [nvidia-x11-470.256.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_3` | [nvidia-x11-470.129.06-6.12.57](https://www.nvidia.com/object/unix.html) | 470.129.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_4` | [nvidia-x11-470.141.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.141.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_5` | [nvidia-x11-470.161.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_6` | [nvidia-x11-470.161.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_7` | [nvidia-x11-470.182.03-6.12.57](https://www.nvidia.com/object/unix.html) | 470.182.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_9` | [nvidia-x11-470.223.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_0` | [nvidia-x11-510.47.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_1` | [nvidia-x11-510.73.08-6.12.57](https://www.nvidia.com/object/unix.html) | 510.73.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_2` | [nvidia-x11-510.85.02-6.12.57](https://www.nvidia.com/object/unix.html) | 510.85.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_3` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_4` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_0` | [nvidia-x11-525.60.13-6.12.57](https://www.nvidia.com/object/unix.html) | 525.60.13 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_1` | [nvidia-x11-525.85.05-6.12.57](https://www.nvidia.com/object/unix.html) | 525.85.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_2` | [nvidia-x11-525.105.17-6.12.57](https://www.nvidia.com/object/unix.html) | 525.105.17 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_3` | [nvidia-x11-525.125.06-6.12.57](https://www.nvidia.com/object/unix.html) | 525.125.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_0` | [nvidia-x11-535.54.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.54.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_1` | [nvidia-x11-535.104.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.104.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_10` | [nvidia-x11-535.247.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.247.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_11` | [nvidia-x11-535.261.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.261.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_12` | [nvidia-x11-535.274.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.274.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_2` | [nvidia-x11-535.129.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_3` | [nvidia-x11-535.154.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.154.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_4` | [nvidia-x11-535.161.07-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_5` | [nvidia-x11-535.161.08-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_6` | [nvidia-x11-535.183.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_7` | [nvidia-x11-535.183.06-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_8` | [nvidia-x11-535.216.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.216.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_9` | [nvidia-x11-535.230.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.230.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_0` | [nvidia-x11-550.54.14-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.14 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_1` | [nvidia-x11-550.54.15-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.15 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_2` | [nvidia-x11-550.90.07-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_3` | [nvidia-x11-550.90.07-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_4` | [nvidia-x11-550.127.05-6.12.57](https://www.nvidia.com/object/unix.html) | 550.127.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_5` | [nvidia-x11-550.144.03-6.12.57](https://www.nvidia.com/object/unix.html) | 550.144.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_6` | [nvidia-x11-550.163.01-6.12.57](https://www.nvidia.com/object/unix.html) | 550.163.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.18_0` | [nvidia-x11-570.124.06-6.12.57](https://www.nvidia.com/object/unix.html) | 570.124.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.18_1` | [nvidia-x11-570.133.20-6.12.57](https://www.nvidia.com/object/unix.html) | 570.133.20 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.18_2` | [nvidia-x11-570.148.08-6.12.57](https://www.nvidia.com/object/unix.html) | 570.148.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.18_3` | [nvidia-x11-570.158.01-6.12.57](https://www.nvidia.com/object/unix.html) | 570.158.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.18_4` | [nvidia-x11-570.172.08-6.12.57](https://www.nvidia.com/object/unix.html) | 570.172.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.18_5` | [nvidia-x11-570.195.03-6.12.57](https://www.nvidia.com/object/unix.html) | 570.195.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.19_0` | [nvidia-x11-580.65.06-6.12.57](https://www.nvidia.com/object/unix.html) | 580.65.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.19_1` | [nvidia-x11-580.82.07-6.12.57](https://www.nvidia.com/object/unix.html) | 580.82.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.19_2` | [nvidia-x11-580.95.05-6.12.57](https://www.nvidia.com/object/unix.html) | 580.95.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.9_2` | [nvidia-x11-430.63-6.12.57](https://www.nvidia.com/object/unix.html) | 430.63 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.11_8` | [nvidia-x11-450.191-6.12.57](https://www.nvidia.com/object/unix.html) | 450.191 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.12_4` | [nvidia-x11-460.107-6.12.57](https://www.nvidia.com/object/unix.html) | 460.107 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_0` | [nvidia-x11-470.63-6.12.57](https://www.nvidia.com/object/unix.html) | 470.63 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_12` | [nvidia-x11-470.256.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_3` | [nvidia-x11-470.129.04-6.12.57](https://www.nvidia.com/object/unix.html) | 470.129.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_4` | [nvidia-x11-470.141.05-6.12.57](https://www.nvidia.com/object/unix.html) | 470.141.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_5` | [nvidia-x11-470.161.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_6` | [nvidia-x11-470.161.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_7` | [nvidia-x11-470.182.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.182.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_9` | [nvidia-x11-470.223.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_0` | [nvidia-x11-510.47.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_1` | [nvidia-x11-510.73.06-6.12.57](https://www.nvidia.com/object/unix.html) | 510.73.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_2` | [nvidia-x11-510.85.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.85.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_3` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_4` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_0` | [nvidia-x11-525.60.12-6.12.57](https://www.nvidia.com/object/unix.html) | 525.60.12 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_1` | [nvidia-x11-525.85.07-6.12.57](https://www.nvidia.com/object/unix.html) | 525.85.07 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_2` | [nvidia-x11-525.105.14-6.12.57](https://www.nvidia.com/object/unix.html) | 525.105.14 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_3` | [nvidia-x11-525.125.03-6.12.57](https://www.nvidia.com/object/unix.html) | 525.125.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_0` | [nvidia-x11-535.54.06-6.12.57](https://www.nvidia.com/object/unix.html) | 535.54.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_1` | [nvidia-x11-535.104.06-6.12.57](https://www.nvidia.com/object/unix.html) | 535.104.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_10` | [nvidia-x11-535.247.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.247.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_11` | [nvidia-x11-535.261.04-6.12.57](https://www.nvidia.com/object/unix.html) | 535.261.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_12` | [nvidia-x11-535.274.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.274.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_2` | [nvidia-x11-535.129.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_3` | [nvidia-x11-535.154.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.154.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_4` | [nvidia-x11-535.161.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_5` | [nvidia-x11-535.161.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_6` | [nvidia-x11-535.183.04-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_7` | [nvidia-x11-535.183.04-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_8` | [nvidia-x11-535.216.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.216.01 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_9` | [nvidia-x11-535.230.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.230.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_0` | [nvidia-x11-550.54.10-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.10 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_1` | [nvidia-x11-550.54.16-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.16 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_2` | [nvidia-x11-550.90.05-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_3` | [nvidia-x11-550.90.05-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_4` | [nvidia-x11-550.127.06-6.12.57](https://www.nvidia.com/object/unix.html) | 550.127.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_5` | [nvidia-x11-550.144.02-6.12.57](https://www.nvidia.com/object/unix.html) | 550.144.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_6` | [nvidia-x11-550.163.02-6.12.57](https://www.nvidia.com/object/unix.html) | 550.163.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.18_0` | [nvidia-x11-570.124.03-6.12.57](https://www.nvidia.com/object/unix.html) | 570.124.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.18_1` | [nvidia-x11-570.133.10-6.12.57](https://www.nvidia.com/object/unix.html) | 570.133.10 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.18_2` | [nvidia-x11-570.148.06-6.12.57](https://www.nvidia.com/object/unix.html) | 570.148.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.18_3` | [nvidia-x11-570.158.02-6.12.57](https://www.nvidia.com/object/unix.html) | 570.158.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.18_4` | [nvidia-x11-570.172.07-6.12.57](https://www.nvidia.com/object/unix.html) | 570.172.07 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.18_5` | [nvidia-x11-570.195.02-6.12.57](https://www.nvidia.com/object/unix.html) | 570.195.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.19_0` | [nvidia-x11-580.65.05-6.12.57](https://www.nvidia.com/object/unix.html) | 580.65.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.19_1` | [nvidia-x11-580.82.02-6.12.57](https://www.nvidia.com/object/unix.html) | 580.82.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.19_2` | [nvidia-x11-580.95.02-6.12.57](https://www.nvidia.com/object/unix.html) | 580.95.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.9_2` | [nvidia-x11-430.67-6.12.57](https://www.nvidia.com/object/unix.html) | 430.67 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.11_8` | [nvidia-x11-450.191-6.12.57](https://www.nvidia.com/object/unix.html) | 450.191 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.12_4` | [nvidia-x11-460.107-6.12.57](https://www.nvidia.com/object/unix.html) | 460.107 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_0` | [nvidia-x11-470.63-6.12.57](https://www.nvidia.com/object/unix.html) | 470.63 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_12` | [nvidia-x11-470.256.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_3` | [nvidia-x11-470.129.04-6.12.57](https://www.nvidia.com/object/unix.html) | 470.129.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_4` | [nvidia-x11-470.141.05-6.12.57](https://www.nvidia.com/object/unix.html) | 470.141.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_5` | [nvidia-x11-470.161.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_6` | [nvidia-x11-470.161.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_7` | [nvidia-x11-470.182.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.182.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_9` | [nvidia-x11-470.223.02-6.12.57](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_0` | [nvidia-x11-510.47.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_1` | [nvidia-x11-510.73.06-6.12.57](https://www.nvidia.com/object/unix.html) | 510.73.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_2` | [nvidia-x11-510.85.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.85.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_3` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_4` | [nvidia-x11-510.108.03-6.12.57](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_0` | [nvidia-x11-525.60.12-6.12.57](https://www.nvidia.com/object/unix.html) | 525.60.12 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_1` | [nvidia-x11-525.85.07-6.12.57](https://www.nvidia.com/object/unix.html) | 525.85.07 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_2` | [nvidia-x11-525.105.14-6.12.57](https://www.nvidia.com/object/unix.html) | 525.105.14 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_3` | [nvidia-x11-525.125.03-6.12.57](https://www.nvidia.com/object/unix.html) | 525.125.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_0` | [nvidia-x11-535.54.06-6.12.57](https://www.nvidia.com/object/unix.html) | 535.54.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_1` | [nvidia-x11-535.104.06-6.12.57](https://www.nvidia.com/object/unix.html) | 535.104.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_10` | [nvidia-x11-535.247.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.247.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_11` | [nvidia-x11-535.261.04-6.12.57](https://www.nvidia.com/object/unix.html) | 535.261.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_12` | [nvidia-x11-535.274.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.274.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_2` | [nvidia-x11-535.129.03-6.12.57](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_3` | [nvidia-x11-535.154.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.154.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_4` | [nvidia-x11-535.161.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_5` | [nvidia-x11-535.161.05-6.12.57](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_6` | [nvidia-x11-535.183.04-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_7` | [nvidia-x11-535.183.04-6.12.57](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_8` | [nvidia-x11-535.216.01-6.12.57](https://www.nvidia.com/object/unix.html) | 535.216.01 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_9` | [nvidia-x11-535.230.02-6.12.57](https://www.nvidia.com/object/unix.html) | 535.230.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_0` | [nvidia-x11-550.54.10-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.10 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_1` | [nvidia-x11-550.54.16-6.12.57](https://www.nvidia.com/object/unix.html) | 550.54.16 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_2` | [nvidia-x11-550.90.05-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_3` | [nvidia-x11-550.90.05-6.12.57](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_4` | [nvidia-x11-550.127.06-6.12.57](https://www.nvidia.com/object/unix.html) | 550.127.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_5` | [nvidia-x11-550.144.02-6.12.57](https://www.nvidia.com/object/unix.html) | 550.144.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_6` | [nvidia-x11-550.163.02-6.12.57](https://www.nvidia.com/object/unix.html) | 550.163.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.18_0` | [nvidia-x11-570.124.03-6.12.57](https://www.nvidia.com/object/unix.html) | 570.124.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.18_1` | [nvidia-x11-570.133.10-6.12.57](https://www.nvidia.com/object/unix.html) | 570.133.10 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.18_2` | [nvidia-x11-570.148.06-6.12.57](https://www.nvidia.com/object/unix.html) | 570.148.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.18_3` | [nvidia-x11-570.158.02-6.12.57](https://www.nvidia.com/object/unix.html) | 570.158.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.18_4` | [nvidia-x11-570.172.07-6.12.57](https://www.nvidia.com/object/unix.html) | 570.172.07 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.18_5` | [nvidia-x11-570.195.02-6.12.57](https://www.nvidia.com/object/unix.html) | 570.195.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.19_0` | [nvidia-x11-580.65.05-6.12.57](https://www.nvidia.com/object/unix.html) | 580.65.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.19_1` | [nvidia-x11-580.82.02-6.12.57](https://www.nvidia.com/object/unix.html) | 580.82.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.19_2` | [nvidia-x11-580.95.02-6.12.57](https://www.nvidia.com/object/unix.html) | 580.95.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.9_2` | [nvidia-x11-430.67-6.12.57](https://www.nvidia.com/object/unix.html) | 430.67 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
</details>

<details>
<summary>Package set: openj9-ibm-semeru (202 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `openj9-ibm-semeru.jdk-bin-11` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.29.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_12_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.12.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_13_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.13.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_14_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_14_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_15_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.15.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_16_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_16_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_17_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.17.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_18_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.18.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_19_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.19.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_20_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.20.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_20_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.20.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_21_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.21.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_22_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.22.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_23_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.23.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_24_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.24.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_24_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.24.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_25_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.25.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_26_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.26.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_27_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.27.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_28_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.28.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-11_0_29_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.29.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-16` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-16_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.17.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_10_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.10.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_11_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.11.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_12_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_12_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_13_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.13.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_14_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.14.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_15_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.15.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_16_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.16.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_17_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.17.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_3_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.3.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_4_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_4_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_5_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.5.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_6_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.6.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_7_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.7.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_8_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.8.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_8_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.8.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_9_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.9.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-18` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-18_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-18_0_1_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-18_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-18_0_2_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-19` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 19.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-19_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 19.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-20` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 20.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-20_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 20.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-20_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 20.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.9.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_3_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.3.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_4_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_4_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_5_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.5.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_6_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.6.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_7_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.7.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_8_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.8.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_9_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.9.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22_0_2_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-23` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-23_0_0_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-23_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-23_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-24` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 24.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-24_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 24.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-25` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 25.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-25_0_0_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 25.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-25_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 25.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.472.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_302_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.302.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_312_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.312.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_322_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.322.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_332_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.332.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_345_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_345_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_352_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.352.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_362_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.362.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_372_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.372.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_382_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.382.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_392_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.392.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_402_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.402.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_412_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.412.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_422_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.422.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_422_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.422.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_432_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.432.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_442_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.442.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_452_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.452.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_462_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.462.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8_0_472_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.472.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.29.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_12_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.12.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_13_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.13.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_14_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_14_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_15_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.15.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_16_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_16_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_17_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.17.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_18_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.18.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_19_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.19.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_20_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.20.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_20_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.20.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_21_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.21.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_22_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.22.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_23_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.23.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_24_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.24.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_24_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.24.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_25_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.25.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_26_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.26.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_27_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.27.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_28_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.28.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-11_0_29_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.29.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-16` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-16_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.17.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_10_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.10.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_11_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.11.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_12_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_12_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_13_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.13.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_14_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.14.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_15_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.15.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_16_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.16.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_17_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.17.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_3_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.3.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_4_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_4_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_5_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.5.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_6_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.6.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_7_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.7.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_8_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.8.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_8_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.8.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_9_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.9.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-18` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-18_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-18_0_1_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-18_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-18_0_2_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-19` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 19.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-19_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 19.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-20` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 20.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-20_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 20.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-20_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 20.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.9.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_3_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.3.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_4_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_4_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_5_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.5.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_6_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.6.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_7_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.7.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_8_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.8.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_9_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.9.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22_0_2_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-23` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-23_0_0_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-23_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-23_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-24` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 24.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-24_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 24.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-25` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 25.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-25_0_0_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 25.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-25_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 25.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.472.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_302_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.302.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_312_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.312.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_322_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.322.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_332_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.332.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_345_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_345_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_352_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.352.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_362_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.362.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_372_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.372.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_382_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.382.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_392_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.392.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_402_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.402.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_412_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.412.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_422_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.422.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_422_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.422.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_432_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.432.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_442_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.442.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_452_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.452.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_462_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.462.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8_0_472_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.472.0 | OpenJ9 binaries built by IBM Semeru |
</details>

<details>
<summary>Package set: openjdk-adoptium (127 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `openjdk-adoptium.jdk-bin-11` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.29_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_14_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.14.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_15_10` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.15_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_16_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.16.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_16_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.16_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_17_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.17_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_18_10` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.18_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_19_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.19_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_20_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.20.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_20_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.20_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_21_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.21_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_22_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.22_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_23_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.23_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_24_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.24_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_25_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.25_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_26_4` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.26_4_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_27_6` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.27_6_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_28_6` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.28_6_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_29_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.29_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-16` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 16.0.2_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-16_0_2_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 16.0.2_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.17_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_10_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.10_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_11_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.11_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_12_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.12_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_13_11` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.13_11_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_14_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.14_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_15_6` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.15_6_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_16_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.16_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_17_10` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.17_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_1_12` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.1_12_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_2_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.2_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_3_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.3_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_4_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.4.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_4_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.4_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_5_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.5_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_6_10` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.6_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_7_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.7_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_8_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.8.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_8_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.8_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_9_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.9_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_0_1_10` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.1_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_0_2_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_0_2_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_36` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18_36_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u472-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u312_b07` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u312-b07 | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u322_b06` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u322-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u332_b09` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u332-b09_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u342_b07` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u342-b07_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u345_b01` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u345-b01_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u352_b08` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u352-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u362_b09` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u362-b09_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u372_b07` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u372-b07_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u382_b05` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u382-b05_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u392_b08` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u392-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u402_b06` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u402-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u412_b08` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u412-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u422_b05` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u422-b05_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u432_b06` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u432-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u442_b06` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u442-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u452_b09` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u452-b09_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u462_b08` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u462-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u472_b08` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u472-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.29_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_14_1_1` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.14.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_15_10` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.15_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_16_1_1` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.16.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_16_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.16_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_17_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.17_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_18_10` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.18_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_19_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.19_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_20_1_1` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.20.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_20_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.20_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_21_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.21_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_22_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.22_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_23_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.23_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_24_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.24_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_25_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.25_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_26_4` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.26_4_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_27_6` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.27_6_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_28_6` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.28_6_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_29_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.29_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.17_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_10_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.10_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_11_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.11_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_12_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.12_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_13_11` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.13_11_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_14_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.14_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_15_6` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.15_6_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_16_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.16_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_17_10` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.17_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_1_12` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.1_12_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_2_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.2_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_3_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.3_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_4_1_1` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.4.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_4_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.4_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_5_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.5_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_6_10` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.6_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_7_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.7_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_8_1_1` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.8.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_8_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.8_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_9_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.9_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-18` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-18_0_1_10` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.1_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-18_0_2_1_1` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-18_0_2_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.2_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u472-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u312_b07` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u312-b07 | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u322_b06` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u322-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u332_b09` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u332-b09_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u342_b07` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u342-b07_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u345_b01` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u345-b01_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u352_b08` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u352-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u362_b09` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u362-b09_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u372_b07` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u372-b07_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u382_b05` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u382-b05_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u392_b08` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u392-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u402_b06` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u402-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u412_b08` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u412-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u422_b05` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u422-b05_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u432_b06` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u432-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u442_b06` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u442-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u452_b09` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u452-b09_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u462_b08` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u462-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u472_b08` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u472-b08_adopt | OpenJDK binaries built by Eclipse Adoptium |
</details>

<details>
<summary>Package set: python3Packages (33 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `python3Packages.bepasty` | [bepasty](https://bepasty-server.readthedocs.org/) | 1.2.2 | Universal pastebin server |
|  | `python3Packages.click-loglevel` | [click-loglevel](https://github.com/jwodder/click-loglevel) | 0.7.0 | Log level parameter type for Click |
|  | `python3Packages.comp128` | [comp128](https://github.com/Takuto88/comp128-python) | 1.0.0 | Python implementation of the Comp128 v1-3 GSM authentication algorithms |
|  | `python3Packages.data-recorder` | [data-recorder](https://github.com/g1879/DataRecorder) | 3.6.2 | Python-based toolkit to record data into files |
|  | `python3Packages.download-kit` | [download-kit](https://github.com/g1879/DownloadKit) | 2.0.7 | Simple to use multi-threaded download toolkit |
|  | `python3Packages.drission-page` | [drission-page](https://github.com/g1879/DrissionPage) | 4.1.1.2 | Python based web automation tool |
|  | `python3Packages.edge-tts` | [edge-tts](https://github.com/rany2/edge-tts) | 7.2.3 | Use Microsoft Edge's online text-to-speech service from Python WITHOUT needing Microsoft Edge or Windows or an API key |
|  | `python3Packages.funasr` | [funasr](https://www.funasr.com/) | 0-unstable-2025-10-01 | Fundamental End-to-End Speech Recognition Toolkit and Open Source SOTA Pretrained Models |
|  | `python3Packages.kaldiio` | [kaldiio](https://github.com/nttcslab-sp/kaldiio) | 2.18.1 | Pure python module for reading and writing kaldi ark files |
|  | `python3Packages.loralib` | [loralib](https://arxiv.org/abs/2106.09685) | 0-unstable-2024-12-16 | Implementation of "LoRA: Low-Rank Adaptation of Large Language Models" |
|  | `python3Packages.modelscope` | [modelscope](https://www.modelscope.cn/) | 1.31.0 | Bring the notion of Model-as-a-Service to life |
|  | `python3Packages.mtkclient` | [mtkclient](https://github.com/bkerler/mtkclient) | 2.0.1.freeze | MTK reverse engineering and flash tool |
|  | `python3Packages.open-webui-kb-manager` | [open-webui-kb-manager](https://github.com/dubh3124/OpenWebUI-KB-Manager) | 0.2.0 | Command-line interface (CLI) tool for managing files and knowledge bases in OpenWebUI |
|  | `python3Packages.opencc-python-reimplemented` | [opencc-python-reimplemented](https://github.com/yichen0831/opencc-python) | 0-unstable-2023-02-11 | OpenCC made with Python |
|  | `python3Packages.ormsgpack` | [ormsgpack](https://github.com/aviramha/ormsgpack) | 1.12.0 | Msgpack serialization/deserialization library for Python, written in Rust using PyO3 and rust-msgpack |
|  | `python3Packages.py-rcon` | [py-rcon](https://github.com/ttk1/py-rcon) | 1.3.0 | Python implementation of RCON |
|  | `python3Packages.pyosmocom` | [pyosmocom](https://gitea.osmocom.org/osmocom/pyosmocom) | 0-unstable-2025-10-23 | Python implementation of key Osmocom protocols/interfaces |
|  | `python3Packages.pysctp` | [pysctp](https://github.com/p1sec/pysctp) | 0.7.2 | SCTP stack for Python |
|  | `python3Packages.pytorch-wpe` | [pytorch-wpe](https://github.com/nttcslab-sp/dnn_wpe) | 0.0.1 | WPE implementation using PyTorch |
|  | `python3Packages.rootutils` | [rootutils](https://pypi.org/project/rootutils/) | 1.0.7 | Simple python package to solve all your problems with pythonpath, work dir, file paths, module imports and environment variables |
|  | `python3Packages.runpod-python` | [runpod-python](https://github.com/runpod/runpod-python) | 1.7.13 | Python library for RunPod API and serverless worker SDK |
|  | `python3Packages.silero-vad` | [silero-vad](https://github.com/snakers4/silero-vad) | 6.1 | Pre-trained enterprise-grade Voice Activity Detector |
|  | `python3Packages.smartrent_py` | [smartrent_py](https://github.com/ZacheryThomas/smartrent.py) | 0.5.2 | Api for SmartRent locks, thermostats, moisture sensors and switches |
|  | `python3Packages.smfc` | [smfc](https://github.com/petersulyok/smfc) | 4.2.1 | Super Micro Fan Control |
|  | `python3Packages.torch-complex` | [torch-complex](https://pypi.org/project/torch-complex) | 0.4.4 | Temporal python class for PyTorch-ComplexTensor |
|  | `python3Packages.tqdm-loggable` | [tqdm-loggable](https://pypi.org/project/tqdm-loggable/) | 0-unstable-2024-10-10 | TQDM progress bar helpers for logging and other headless application |
|  | `python3Packages.vector-quantize-pytorch` | [vector-quantize-pytorch](https://github.com/lucidrains/vector-quantize-pytorch) | 1.24.2 | Vector (and Scalar) Quantization, in Pytorch |
|  | `python3Packages.xstatic-asciinema-player` | [xstatic-asciinema-player](https://github.com/asciinema/asciinema-player) | 2.6.1.1 | Asciinema-player packaged for setuptools (easy_install) / pip |
|  | `python3Packages.xstatic-font-awesome` | [xstatic-font-awesome](https://github.com/FortAwesome/Font-Awesome) | 4.7.0.0 | Font Awesome packaged for setuptools (easy_install) / pip |
|  | `python3Packages.xue` | [xue](https://pypi.org/project/xue/) | 0.0.34 | Minimalist web front-end framework composed of HTMX and Python |
| `Broken` | `python3Packages.coqui-tts` | [coqui-tts](http://coqui.ai) | 0.22.0 | Deep learning toolkit for Text-to-Speech, battle-tested in research and production |
| `Broken` | `python3Packages.fish-speech` | [fish-speech](https://speech.fish.audio/) | 1.5.1 | SOTA Open Source TTS |
| `Broken` | `python3Packages.kui` | [kui](https://kui.aber.sh/) | 1.14.0 | Easy-to-use web framework |
</details>

<details>
<summary>Package set: th-fonts (9 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `th-fonts.hak` | [th-hak](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-hak font |
|  | `th-fonts.joeng` | [th-joeng](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-joeng font |
|  | `th-fonts.khaai-p` | [th-khaai-p](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-khaai-p font |
|  | `th-fonts.khaai-t` | [th-khaai-t](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-khaai-t font |
|  | `th-fonts.ming` | [th-ming](http://cheonhyeong.com/Simplified/download.html) | 5.0.0 | TianHeng th-ming font |
|  | `th-fonts.sung-p` | [th-sung-p](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-sung-p font |
|  | `th-fonts.sung-t` | [th-sung-t](http://cheonhyeong.com/Simplified/download.html) | 4.1.0 | TianHeng th-sung-t font |
|  | `th-fonts.sy` | [th-sy](http://cheonhyeong.com/Simplified/download.html) | 4.1.0 | TianHeng th-sy font |
|  | `th-fonts.tshyn` | [th-tshyn](http://cheonhyeong.com/Simplified/download.html) | 5.0.0 | TianHeng th-tshyn font |
</details>

<details>
<summary>Package set: uncategorized (142 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `uncategorized.adspower` | [adspower](https://www.adspower.com/) | 7.3.26 | Antidetect Browser for Multi-Accounts |
|  | `uncategorized.amule-dlp` | [amule-dlp](https://github.com/persmule/amule-dlp) | 2.3.2-unstable-2023-03-02 | Peer-to-peer client for the eD2K and Kademlia networks (with Dynamic Leech Protection) |
|  | `uncategorized.asterisk-g72x` | [asterisk-g72x](https://github.com/arkadijs/asterisk-g72x) | 0-unstable-2025-09-01 | G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled) |
|  | `uncategorized.axiom-syslog-proxy` | [axiom-syslog-proxy](https://github.com/axiomhq/axiom-syslog-proxy) | 0.8.0 | Syslog push interface to Axiom |
| `x86_64-linux` | `uncategorized.baidunetdisk` | [baidunetdisk](https://pan.baidu.com/) | 4.17.7 | Baidu Netdisk |
|  | `uncategorized.baidupcs-go` | [baidupcs-go](https://github.com/qjfoidnh/BaiduPCS-Go) | 4.0.0-unstable-2025-10-29 | Baidu Netdisk commandline client, mimicking Linux shell file handling commands |
|  | `uncategorized.bilibili` | [bilibili](https://app.bilibili.com/) | 1.17.2-2 | Desktop client for Bilibili |
|  | `uncategorized.bin-cpuflags-x86` | [bin-cpuflags-x86](https://github.com/HanabishiRecca/bin-cpuflags-x86) | 1.0.3 | Small CLI tool to detect CPU flags (instruction sets) of X86 binaries |
|  | `uncategorized.bird-lg-go` | [bird-lg-go](https://github.com/xddxdd/bird-lg-go) | 1.3.12.1 | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
|  | `uncategorized.bird-lgproxy-go` | [bird-lgproxy-go](https://github.com/xddxdd/bird-lg-go) | 1.3.12.1 | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
|  | `uncategorized.bnxtnvm` | [bnxtnvm](https://resource.fs.com/mall/resource/broadcom-ethernet-network-adapter-user-manual.pdf) | 222.0.144.0 | Broadcom BNXTNVM utility |
|  | `uncategorized.boringssl-oqs` | [boringssl-oqs](https://openquantumsafe.org) | 0-unstable-2025-08-31 | Fork of BoringSSL that includes prototype quantum-resistant key exchange and authentication in the TLS handshake based on liboqs |
|  | `uncategorized.browser360` | [browser360](https://browser.360.net/gc/index.html) | 13.4.1000.77 | Browser from 360 |
|  | `uncategorized.calibre-cops` | [calibre-cops](http://blog.slucas.fr/en/oss/calibre-opds-php-server) | 3.7.8 | Web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks |
|  | `uncategorized.cockpy` | [cockpy](https://github.com/Hiro420/CockPY) | 0-unstable-2024-09-07 | Public and open source version of the cbt2 ps im working on |
|  | `uncategorized.dbip-lite` | [dbip-lite](https://db-ip.com/db/lite.php) | 2025-11 | DBIP's Lite GeoIP Country, City, and ASN databases |
|  | `uncategorized.decluttarr` | [decluttarr](https://github.com/ManiMatter/decluttarr) | 1.50.2 | Watches radarr, sonarr, lidarr and readarr download queues and removes downloads if they become stalled or no longer needed |
|  | `uncategorized.deeplx` | [deeplx](https://deeplx.owo.network) | 1.1.0 | Powerful Free DeepL API, No Token Required |
| `x86_64-linux` | `uncategorized.dingtalk` | [dingtalk](https://www.dingtalk.com/) | 7.6.45.5041701 | Enterprise communication and collaboration platform developed by Alibaba Group |
|  | `uncategorized.dn42-pingfinder` | [dn42-pingfinder](https://git.dn42.dev/dn42/pingfinder/src/branch/master/clients) | 1.2.1-unstable-2022-11-06 | DN42 Pingfinder |
|  | `uncategorized.drone-file-secret` | [drone-file-secret](https://github.com/xddxdd/drone-file-secret) | 0-unstable-2023-06-25 | Secret provider for Drone CI that reads secrets from a given folder |
|  | `uncategorized.drone-vault` | [drone-vault](https://docs.drone.io/configure/secrets/external/vault/) | 1.3.0 | Drone plugin for integrating with the Vault secrets manager |
|  | `uncategorized.dump978` | [dump978](https://github.com/flightaware/dump978) | 10.2 | FlightAware's 978MHz UAT demodulator |
|  | `uncategorized.electron_11` | [electron](https://github.com/electron/electron) | 11.5.0 | Cross platform desktop application shell |
|  | `uncategorized.etherguard` | [etherguard](https://github.com/KusakabeShi/EtherGuard-VPN) | 0.3.5-f5 | Layer 2 version of WireGuard with Floyd Warshall implementation in Go |
|  | `uncategorized.fake-ollama` | [fake-ollama](https://github.com/spoonnotfound/fake-ollama) | 0-unstable-2025-02-14 | Simulated server implementation of Ollama API |
|  | `uncategorized.fastapi-dls` | [fastapi-dls](https://gitea.publichub.eu/oscar.krause/fastapi-dls) | 2.0.1-unstable-2025-05-13 | Minimal Delegated License Service (DLS) |
|  | `uncategorized.fcitx5-breeze` | [fcitx5-breeze](https://github.com/scratch-er/fcitx5-breeze) | 3.1.0 | Fcitx5 theme to match KDE's Breeze style |
|  | `uncategorized.flapalerted` | [flapalerted](https://github.com/Kioubit/FlapAlerted) | 3.14.3 | BGP Update based flap detection |
|  | `uncategorized.flaresolverr-21hsmw` | [flaresolverr-21hsmw](https://github.com/21hsmw/FlareSolverr) | 0-unstable-2025-03-04 | Proxy server to bypass Cloudflare protection, with 21hsmw modifications to support nodriver |
|  | `uncategorized.flaresolverr-alexfozor` | [flaresolverr-alexfozor](https://github.com/AlexFozor/FlareSolverr) | 0-unstable-2024-08-04 | Proxy server to bypass Cloudflare protection, with AlexFozor modifications to support Drission Page |
|  | `uncategorized.fr24feed` | [fr24feed](https://www.flightradar24.com/share-your-data) | 1.0.54-0 | Flightradar24 Decoder & Feeder lets you effortlessly share ADS-B data with Flightradar24 |
|  | `uncategorized.ftp-proxy` | [ftp-proxy](http://www.ftpproxy.org/) | 1.2.3 | FTP Proxy Server |
|  | `uncategorized.geolite2` | [geolite2](https://dev.maxmind.com/geoip/geoip2/geolite2/) | 2025.11.04 | MaxMind's GeoIP2 GeoLite2 Country, City, and ASN databases |
|  | `uncategorized.glauth` | [glauth](https://github.com/glauth/glauth) | 2.4.0 | Lightweight LDAP server for development, home use, or CI |
| `x86_64-linux` | `uncategorized.google-earth-pro` | [google-earth-pro](https://www.google.com/earth/) | 7.3.6.10441 | World sphere viewer |
|  | `uncategorized.gopherus` | [gopherus](http://gopherus.sourceforge.net/) | 1.2.2 | Free, multiplatform, console-mode gopher client that provides a classic text interface to the gopherspace |
|  | `uncategorized.gost-engine` | [gost-engine](https://github.com/gost-engine/engine) | 3.0.3 | Reference implementation of the Russian GOST crypto algorithms for OpenSSL |
|  | `uncategorized.grasscutter` | [grasscutter](https://github.com/Grasscutters/Grasscutter) | 1.7.4 | Server software reimplementation for a certain anime game |
| `x86_64-linux` | `uncategorized.gst-plugin-crystalhd` | [gst-plugin-crystalhd](https://launchpad.net/ubuntu/+source/crystalhd) | 0-unstable-2020-03-22 | Broadcom Crystal HD Hardware Decoder (BCM70012/70015) GStreamer plugin |
|  | `uncategorized.gwmp-mux` | [gwmp-mux](https://github.com/helium/gwmp-mux) | 0.11.0 | Multiplexer for Semtech's GWMP over UDP |
|  | `uncategorized.hack3ric-flow` | [hack3ric-flow](https://github.com/hack3ric/flow) | 0.2.0-unstable-2025-09-28 | BGP flowspec executor |
|  | `uncategorized.hath` | [hath](https://e-hentai.org/) | 1.6.2 | Hentai@Home |
|  | `uncategorized.helium-gateway-rs` | [helium-gateway-rs](https://github.com/helium/gateway-rs) | 1.3.0-unstable-2025-04-11 | Helium Gateway |
|  | `uncategorized.hesuvi-hrir` | [hesuvi-hrir](https://sourceforge.net/projects/hesuvi/) | 2.0.0.1 | Headphone Surround Virtualizations for Equalizer APO |
|  | `uncategorized.hi3-ii-martian-font` | [hi3-ii-martian-font](https://github.com/Wenti-D/HI3IIMartianFont) | 0-unstable-2023-10-12 | Font for Martian in Honkai Impact 3rd |
|  | `uncategorized.hoyo-glyphs` | [hoyo-glyphs](https://github.com/SpeedyOrc-C/Hoyo-Glyphs) | 20250529 | Constructed scripts by Hoyoverse 米哈游的架空文字 |
|  | `uncategorized.igsc` | [igsc](https://github.com/intel/igsc) | 1.0.0 | Intel graphics system controller firmware update library |
|  | `uncategorized.imewlconverter` | [imewlconverter](https://github.com/studyzy/imewlconverter) | 3.2.0 | FOSS program for converting IME dictionaries |
|  | `uncategorized.jproxy` | [jproxy](https://github.com/LuckyPuppy514/jproxy) | 3.4.1 | Proxy between Sonarr / Radarr and Jackett / Prowlarr, mainly used to optimize search and improve recognition rate |
|  | `uncategorized.kaixinsong-fonts` | [kaixinsong-fonts](http://www.guoxuedashi.net/zidian/bujian/KaiXinSong.php) | 3.0 | KaiXinSong |
|  | `uncategorized.kikoplay` | [kikoplay](https://kikoplay.fun) | 2.0.0 | More than a Full-Featured Danmu Player |
|  | `uncategorized.konnect` | [konnect](https://github.com/Kopano-dev/konnect) | 0.34.0 | Kopano Konnect implements an OpenID provider (OP) with integrated web login and consent forms |
|  | `uncategorized.ldap-auth-proxy` | [ldap-auth-proxy](https://github.com/pinepain/ldap-auth-proxy) | 0.2.0-unstable-2020-07-29 | Simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend |
| `x86_64-linux` | `uncategorized.libcrystalhd` | [libcrystalhd](https://launchpad.net/ubuntu/+source/crystalhd) | 0-unstable-2021-01-26 | Broadcom Crystal HD Hardware Decoder (BCM70012/70015) userspace library |
|  | `uncategorized.libnftnl-fullcone` | [libnftnl](https://netfilter.org/projects/libnftnl/) | 1.3.0 | Userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem |
|  | `uncategorized.liboqs` | [liboqs](https://openquantumsafe.org) | 0.14.0 | C library for prototyping and experimenting with quantum-resistant cryptography |
|  | `uncategorized.liboqs-unstable` | [liboqs](https://openquantumsafe.org) | 0-unstable-2025-11-04 | C library for prototyping and experimenting with quantum-resistant cryptography |
| `x86_64-linux` | `uncategorized.libqcef` | [libqcef](https://github.com/martyr-deepin/libqcef) | 0-unstable-2019-11-23 | Qt5 binding of CEF |
| `x86_64-linux` | `uncategorized.linguaspark-server` | [linguaspark-server](https://github.com/LinguaSpark/server) | 0-unstable-2025-10-12 | Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs |
| `x86_64-linux` | `uncategorized.linguaspark-server-x86-64-v3` | [linguaspark-server](https://github.com/LinguaSpark/server) | 0-unstable-2025-10-12 | Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs |
|  | `uncategorized.lyrica` | [lyrica](https://github.com/chiyuki0325/lyrica) | 0.14-1 | Linux desktop lyrics widget focused on simplicity and integration |
|  | `uncategorized.lyrica-plasmoid` | [lyrica](https://github.com/chiyuki0325/lyrica) | 0.14-1 | Linux desktop lyrics widget focused on simplicity and integration (Plasmoid component) |
|  | `uncategorized.magiskboot` | [magiskboot](https://topjohnwu.github.io/Magisk/tools.html) | 29.0 | Tool to unpack / repack boot images, parse / patch / extract cpio, patch dtb, hex patch binaries, and compress / decompress files with multiple algorithms |
|  | `uncategorized.mautrix-gmessages` | [mautrix-gmessages](https://github.com/mautrix/gmessages) | 0.2510.0 | Matrix-Google Messages puppeting bridge |
|  | `uncategorized.metee` | [metee](https://github.com/intel/metee) | 6.0.2 | C library to access CSE/CSME/GSC firmware via a MEI interface |
| `x86_64-linux` | `uncategorized.mtranservercore-rs` | [linguaspark-server](https://github.com/LinguaSpark/server) | 0-unstable-2025-10-12 | Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs |
|  | `uncategorized.ncmdump-rs` | [ncmdump-rs](https://github.com/iqiziqi/ncmdump.rs) | 0.8.0 | NetEase Cloud Music copyright protection file dump by rust |
|  | `uncategorized.netboot-xyz` | [netboot-xyz](https://netboot.xyz/) | 2.0.88 | Network-based bootable operating system installer based on iPXE |
| `x86_64-linux` | `uncategorized.netease-cloud-music` | [netease-cloud-music](https://music.163.com) | 1.2.1 | NetEase Cloud Music Linux Client (package script adapted from NixOS-CN and Freed-Wu) |
|  | `uncategorized.netns-exec` | [netns-exec](https://github.com/pekman/netns-exec) | 0-unstable-2016-07-30 | Run command in Linux network namespace as normal user |
|  | `uncategorized.nftables-fullcone` | [nftables](https://netfilter.org/projects/nftables/) | 1.1.5 | Project that aims to replace the existing {ip,ip6,arp,eb}tables framework |
|  | `uncategorized.noise-suppression-for-voice` | [noise-suppression-for-voice](https://github.com/werman/noise-suppression-for-voice) | 1.10 | Noise suppression plugin based on Xiph's RNNoise |
|  | `uncategorized.nullfs` | [nullfs](https://github.com/xrgtn/nullfs) | 0-unstable-2016-01-28 | FUSE nullfs drivers |
|  | `uncategorized.nvlax` | [nvlax](https://github.com/illnyang/nvlax) | unstable-2021-10-29 | Future-proof NvENC & NvFBC patcher |
|  | `uncategorized.nvlax-530` | [nvlax](https://github.com/illnyang/nvlax) | unstable-2021-10-29 | Future-proof NvENC & NvFBC patcher (for NVIDIA driver >= 530) |
|  | `uncategorized.oci-arm-host-capacity` | [oci-arm-host-capacity](https://github.com/hitrov/oci-arm-host-capacity) | 0-unstable-2024-08-13 | This script allows to bypass Oracle Cloud Infrastructure 'Out of host capacity' error immediately when additional OCI capacity will appear in your Home Region / Availability domain |
|  | `uncategorized.one-api` | [one-api](https://openai.justsong.cn) | 0.6.10 | OpenAI key management & redistribution system, using a single API for all LLMs |
|  | `uncategorized.openai-edge-tts` | [openai-edge-tts](https://tts.travisvn.com/) | 0-unstable-2025-07-01 | Text-to-speech API endpoint compatible with OpenAI's TTS API endpoint, using Microsoft Edge TTS to generate speech for free locally |
|  | `uncategorized.openedai-speech` | [openedai-speech](https://github.com/matatonic/openedai-speech) | 0.18.2 | OpenAI API compatible text to speech server using Coqui AI's xtts_v2 and/or piper tts as the backend |
|  | `uncategorized.openssl-ech` | [openssl-ech](https://github.com/sftcd/openssl/tree/ECH-draft-13c) | 0-unstable-2025-05-30 | OpenSSL with Encrypted Client Hello support |
|  | `uncategorized.openssl-oqs-provider` | [openssl-oqs-provider](https://openquantumsafe.org) | 0.10.0 | OpenSSL 3 provider containing post-quantum algorithms |
|  | `uncategorized.openvswitch-dpdk` | [openvswitch-dpdk](https://www.openvswitch.org/) | 3.6.0 | Multilayer virtual switch |
|  | `uncategorized.osdlyrics` | [osdlyrics](https://github.com/osdlyrics/osdlyrics) | 0.5.15 | Standalone lyrics fetcher/displayer (windowed and OSD mode) |
|  | `uncategorized.palworld-exporter` | [palworld-exporter](https://github.com/palworldlol/palworld-exporter) | 1.3.1 | Prometheus exporter for Palword Server |
|  | `uncategorized.palworld-worldoptions` | [palworld-worldoptions](https://github.com/legoduded/palworld-worldoptions) | 1.11.0 | Tool for managing Palworld dedicated server settings |
|  | `uncategorized.peerbanhelper` | [peerbanhelper](https://github.com/Ghost-chu/PeerBanHelper) | 9.0.10 | Automatically bans unwanted, leeching, and anomalous BT clients, with support for custom rules for qBittorrent and Transmission |
|  | `uncategorized.phpmyadmin` | [phpmyadmin](https://www.phpmyadmin.net/) | 5.2.3 | Web interface for MySQL and MariaDB |
|  | `uncategorized.phppgadmin` | [phppgadmin](https://github.com/phppgadmin/phppgadmin) | 7.14.7-mod | Premier web-based administration tool for PostgreSQL |
|  | `uncategorized.plangothic-fonts` | [plangothic-fonts](https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project) | 2.9.5787 | Plangothic Project |
|  | `uncategorized.plasma-panel-transparency-toggle` | [plasma-panel-transparency-toggle](https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6) | 0-unstable-2024-04-17 | Rewrite of Panel Transparency Button for Plasma 6 |
|  | `uncategorized.plasma-smart-video-wallpaper-reborn` | [plasma-smart-video-wallpaper-reborn](https://store.kde.org/p/2139746) | 2.4.0 | Plasma 6 wallpaper plugin to play videos on your Desktop/Lock Screen |
|  | `uncategorized.plasma-yesplaymusic-lyric` | [plasma-yesplaymusic-lyric](https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics) | 0.2.3-unstable-2025-01-07 | Display YesPlayMusic lyrics on the plasma panel | 在KDE plasma面板中显示YesPlayMusic的歌词 |
|  | `uncategorized.pterodactyl-wings` | [pterodactyl-wings](https://pterodactyl.io) | 1.11.13-unstable-2025-11-01 | Server control plane for Pterodactyl Panel |
|  | `uncategorized.pyhss` | [pyhss](https://github.com/nickvsnetworking/pyhss) | 1.0.2-unstable-2025-04-03 | Python HSS / Diameter Server |
|  | `uncategorized.qemu-user-static` | [qemu-user-static](http://www.qemu.org/) | 10.1.2+ds-2 | Generic and open source machine emulator and virtualizer |
|  | `uncategorized.qq` | [qq](https://im.qq.com/linuxqq/index.html) | 3.2.18 | Desktop client for QQ on Linux |
| `x86_64-linux` | `uncategorized.qqmusic` | [qqmusic](https://y.qq.com/) | 1.1.8 | Tencent QQ Music |
|  | `uncategorized.qqsp` | [qqsp](https://github.com/Sonnix1/Qqsp) | 1.9 | QT Quest Soft Player is a interactive fiction stories and games player (compatible fork of qsp.su) |
|  | `uncategorized.qsp` | [qsp](https://github.com/QSPFoundation/qspgui) | 5.9.4-b1-unstable-2025-10-21 | Interactive Fiction development platform (GUI application) |
|  | `uncategorized.qsp-lib` | [qsp-lib](https://github.com/QSPFoundation/qsp) | 0-unstable-2025-11-04 | Interactive fiction development platform (Game Library) |
| `x86_64-linux` | `uncategorized.red-star-os-rgjanggi` | [red-star-os-rgjanggi](https://archive.org/details/RedStarOS) | 3.0 | Rgjanggi game from DPRK Red Star OS 3.0, heavily sandboxed, use at your own risk |
|  | `uncategorized.red-star-os-wallpapers` | [red-star-os-wallpapers](https://archive.org/details/RedStarOS) | 3.0 | Wallpapers from DPRK Red Star OS 3.0 |
|  | `uncategorized.rime-aurora-pinyin` | [rime-aurora-pinyin](https://github.com/hosxy/rime-aurora-pinyin) | 0-unstable-2022-08-28 | 【极光拼音】输入方案 |
|  | `uncategorized.rime-custom-pinyin-dictionary` | [rime-custom-pinyin-dictionary](https://github.com/wuhgit/CustomPinyinDictionary) | 20250101 | 自建拼音输入法词库，百万常用词汇量，适配 Fcitx5 (Linux / Android) 及 Gboard (Android + Magisk or KernelSU) 。 |
|  | `uncategorized.rime-dict` | [rime-dict](https://github.com/Iorest/rime-dict) | 0-unstable-2020-12-26 | RIME 词库增强 |
|  | `uncategorized.rime-ice` | [rime-ice](https://dvel.me/posts/rime-ice/) | 0-unstable-2025-11-04 | Rime 配置：雾凇拼音 | 长期维护的简体词库 |
|  | `uncategorized.rime-moegirl` | [rime-moegirl](https://github.com/outloudvi/mw2fcitx/releases) | 20251009 | RIME dictionary file for entries from zh.moegirl.org.cn |
|  | `uncategorized.rime-zhwiki` | [rime-zhwiki](https://github.com/felixonmars/fcitx5-pinyin-zhwiki) | 20250823 | RIME dictionary file for entries from zh.wikipedia.org |
|  | `uncategorized.route-chain` | [route-chain](https://github.com/xddxdd/route-chain) | 0-unstable-2023-09-09 | Small app to generate a long path in traceroute |
|  | `uncategorized.rtpengine` | [rtpengine](https://github.com/sipwise/rtpengine) | mr13.3.1.4 | Sipwise media proxy for Kamailio |
|  | `uncategorized.runpodctl` | [runpodctl](https://www.runpod.io) | 1.14.11 | RunPod CLI for pod management |
|  | `uncategorized.sam-toki-mouse-cursors` | [sam-toki-mouse-cursors](https://github.com/SamToki/Sam-Toki-Mouse-Cursors) | 9.04 | Original mouse cursors (pointers) for Windows, with minimalistic design |
| `x86_64-linux` | `uncategorized.sgx-software-enable` | [sgx-software-enable](https://github.com/intel/sgx-software-enable) | 1.0-unstable-2023-01-06 | Application to enable Intel SGX on Linux systems |
|  | `uncategorized.sidestore-vpn` | [sidestore-vpn](https://github.com/xddxdd/sidestore-vpn) | 0-unstable-2025-06-27 | Allow SideStore to work across all iOS devices on your local network |
|  | `uncategorized.space-cadet-pinball-full-tilt` | [SpaceCadetPinball](https://github.com/k4zmu2a/SpaceCadetPinball) | 2.1.0 | Reverse engineering of 3D Pinball for Windows – Space Cadet, a game bundled with Windows (With Full Tilt Pinball data) |
|  | `uncategorized.suwayomi-server` | [suwayomi-server](https://github.com/Suwayomi/Suwayomi-Server) | 2.1.1867 | Rewrite of Tachiyomi for the Desktop |
| `x86_64-linux` | `uncategorized.svp` | [svp](https://www.svp-team.com/wiki/SVP:Linux) | 4.6.263 | SmoothVideo Project 4 (SVP4) converts any video to 60 fps (and even higher) and performs this in real time right in your favorite video player |
|  | `uncategorized.svp-mpv` | [mpv-with-scripts-0.40.0](https://mpv.io) |  | General-purpose media player, fork of MPlayer and mplayer2 |
|  | `uncategorized.sx1302-hal` | [sx1302-hal](https://github.com/NebraLtd/sx1302_hal) | 2.1.0-unstable-2023-02-06 | SX1302/SX1303 Hardware Abstraction Layer and tools |
|  | `uncategorized.uesave` | [uesave](https://github.com/trumank/uesave-rs) | 0.6.2 | Library for reading and writing Unreal Engine save files (commonly referred to as GVAS) |
|  | `uncategorized.uesave-0_3_0` | [uesave](https://github.com/trumank/uesave-rs) | 0.3.0 | Library for reading and writing Unreal Engine save files (commonly referred to as GVAS), older version that works with Palworld |
|  | `uncategorized.uni-api` | [uni-api](https://github.com/yym68686/uni-api) | 0-unstable-2025-11-04 | Unifies the management of LLM APIs across multiple backend services |
| `x86_64-linux` | `uncategorized.unigine-heaven` | [unigine-heaven](https://benchmark.unigine.com/heaven) | 4.0 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `uncategorized.unigine-sanctuary` | [unigine-sanctuary](https://benchmark.unigine.com/sanctuary) | 2.3 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `uncategorized.unigine-superposition` | [unigine-superposition](https://benchmark.unigine.com/superposition) | 1.1 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `uncategorized.unigine-tropics` | [unigine-tropics](https://benchmark.unigine.com/tropics) | 1.3 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `uncategorized.unigine-valley` | [unigine-valley](https://benchmark.unigine.com/valley) | 1.0 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
|  | `uncategorized.usque` | [usque](https://github.com/Diniboy1123/usque) | 1.4.2 | Open-source reimplementation of the Cloudflare WARP client's MASQUE protocol |
|  | `uncategorized.vbmeta-disable-verification` | [vbmeta-disable-verification](https://github.com/libxzr/vbmeta-disable-verification) | 1.0 | Patch Android vbmeta image and disable verification flags inside |
|  | `uncategorized.vgpu-unlock-rs` | [vgpu-unlock-rs](https://github.com/mbilker/vgpu_unlock-rs) | 2.5.0 | Unlock vGPU functionality for consumer grade GPUs |
|  | `uncategorized.vk-hdr-layer` | [vk-hdr-layer](https://github.com/Zamundaaa/VK_hdr_layer) | 0-unstable-2025-07-31 | Vulkan layer utilizing a small color management / HDR protocol for experimentation |
|  | `uncategorized.vlmcsd` | [vlmcsd](https://github.com/Wind4/vlmcsd) | 1113-unstable-2023-07-28 | KMS Emulator in C |
|  | `uncategorized.vpp` | [vpp](https://wiki.fd.io/view/VPP/What_is_VPP%3F) | 25.10 | Vector Packet Processing |
|  | `uncategorized.vuetorrent-backend` | [vuetorrent-backend](https://github.com/VueTorrent/vuetorrent-backend) | 2.7.0 | FSimple backend service to store configuration server-side |
|  | `uncategorized.wechat-uos-sandboxed` | [wechat-uos](https://weixin.qq.com/) | 4.0.1.12 | WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `x86_64-linux` | `uncategorized.wine-wechat` | [wine-wechat](https://weixin.qq.com/) | 3.9.12.57 | Wine WeChat x64 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat) |
| `x86_64-linux` | `uncategorized.wine-wechat-x86` | [wine-wechat-x86](https://weixin.qq.com/) | 3.9.12.56 | Wine WeChat x86 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat) |
|  | `uncategorized.xvcd` | [xvcd](https://github.com/RHSResearchLLC/xvcd) | 0-unstable-2019-11-20 | Xilinx Virtual Cable Daemon |
| `Broken` | `uncategorized.douban-openapi-server` | [douban-openapi-server](https://github.com/caryyu/douban-openapi-server) | 0-unstable-2022-12-17 | Douban API server that provides an unofficial APIs for media information gathering |
| `Broken` | `uncategorized.soggy` | [soggy](https://github.com/LDAsuku/soggy) | 0-unstable-2022-12-14 | Experimental server emulator for a game I forgot its name |
| `Broken` | `uncategorized.uksmd` | [uksmd](https://github.com/CachyOS/uksmd) | 1.3.0 | Userspace KSM helper daemon |
</details>

