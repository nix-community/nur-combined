# Lan Tian's NUR Packages

![Build and populate cache](https://github.com/xddxdd/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fxddxdd%2Fnur-packages)](https://garnix.io)

## Warning

This NUR contains packages customized for my own use. These packages reside in `lantianCustomized`, `lantianLinuxXanmod` and `lantianPersonal` categories. I do not ensure that they stay backwards compatible or functionally stable, nor do I accept any requests to tailor them for public use.

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
<summary>Package set: (Uncategorized) (141 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `acpi-ec` | [acpi-ec](https://github.com/musikid/acpi_ec) | 1.0.4 | Kernel module to access directly to the ACPI EC |
|  | `amule-dlp` | [amule-dlp](https://github.com/amule-project/amule) | unstable-2023-03-02 | Peer-to-peer client for the eD2K and Kademlia networks |
|  | `ast` | [ast](https://www.aspeedtech.com/support_driver/) | 1.14.3_3 | Aspeed Graphics Driver |
|  | `asterisk-g72x` | [asterisk-g72x](https://github.com/arkadijs/asterisk-g72x) | unstable-2024-10-12 | G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled) |
|  | `axiom-syslog-proxy` | [axiom-syslog-proxy](https://github.com/axiomhq/axiom-syslog-proxy) | 0.7.2 | Syslog push interface to Axiom |
| `x86_64-linux` | `baidunetdisk` | [baidunetdisk](https://pan.baidu.com/) | 4.17.7 | Baidu Netdisk |
|  | `baidupcs-go` | [baidupcs-go](https://github.com/qjfoidnh/BaiduPCS-Go) | 3.9.5 | Baidu Netdisk commandline client, mimicking Linux shell file handling commands |
|  | `bepasty` | [bepasty](https://bepasty-server.readthedocs.org/) | 1.2.1 | Universal pastebin server |
|  | `bilibili` | [bilibili](https://app.bilibili.com/) | 1.14.2-1 | Bilibili desktop client |
|  | `bird-lg-go` | [bird-lg-go](https://github.com/xddxdd/bird-lg-go) | 1.3.8 | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
|  | `bird-lgproxy-go` | [bird-lgproxy-go](https://github.com/xddxdd/bird-lg-go) | 1.3.8 | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
|  | `boringssl-oqs` | [boringssl-oqs](https://openquantumsafe.org) | unstable-2024-10-09 | Fork of BoringSSL that includes prototype quantum-resistant key exchange and authentication in the TLS handshake based on liboqs |
|  | `browser360` | [browser360](https://browser.360.net/gc/index.html) | 13.3.1016.4 | 360 Browser |
|  | `calibre-cops` | [calibre-cops](http://blog.slucas.fr/en/oss/calibre-opds-php-server) | 3.4.5 | Calibre OPDS (and HTML) PHP Server : web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks (epub, mobi, pdf, ...) |
|  | `chmlib-utils` | [chmlib](http://www.jedrea.com/chmlib) | 0.40a | Library for dealing with Microsoft ITSS/CHM format files |
|  | `click-loglevel` | [click-loglevel](https://github.com/jwodder/click-loglevel) | 0.5.0 | Log level parameter type for Click |
|  | `cloudpan189-go` | [cloudpan189-go](https://github.com/tickstep/cloudpan189-go) | 0.1.3 | CLI for China Telecom 189 Cloud Drive service, implemented in Go |
|  | `cockpy` | [cockpy](https://github.com/Hiro420/CockPY) | unstable-2024-09-07 | Public and open source version of the cbt2 ps im working on |
|  | `cryptodev-unstable` | [cryptodev-linux](http://cryptodev-linux.org/) | unstable-2024-10-10 | Device that allows access to Linux kernel cryptographic drivers |
|  | `decluttarr` | [decluttarr](https://github.com/ManiMatter/decluttarr) | 1.50.0 | Watches radarr, sonarr, lidarr and readarr download queues and removes downloads if they become stalled or no longer needed |
| `x86_64-linux` | `deepspeech-gpu` | [deepspeech-gpu](https://github.com/mozilla/DeepSpeech) | 0.9.3 | Speech-to-text engine which can run in real time on devices ranging from a Raspberry Pi 4 to high power GPU servers |
| `x86_64-linux` | `deepspeech-wrappers` | [deepspeech](https://github.com/mozilla/DeepSpeech) | 0.9.3 | Speech-to-text engine which can run in real time on devices ranging from a Raspberry Pi 4 to high power GPU servers |
| `x86_64-linux` | `dingtalk` | [dingtalk](https://www.dingtalk.com/) | 7.6.15.4102301 | 钉钉 |
|  | `dn42-pingfinder` | [dn42-pingfinder](https://git.dn42.dev/dn42/pingfinder/src/branch/master/clients) | 1.0.0 | DN42 Pingfinder |
| `Broken` | `douban-openapi-server` | [douban-openapi-server](https://github.com/caryyu/douban-openapi-server) | unstable-2022-12-17 | Douban API server that provides an unofficial APIs for media information gathering |
|  | `dpdk-kmod` | [dpdk-kmod](https://git.dpdk.org/dpdk-kmods/) | unstable-2023-02-05 | DPDK kernel modules or add-ons |
|  | `drone-file-secret` | [drone-file-secret](https://github.com/xddxdd/drone-file-secret) | unstable-2023-06-25 | Secret provider for Drone CI. It simply reads secrets from a given folder, suitable for private use Drone CI instances where running a Vault instance can be undesirable |
|  | `drone-vault` | [drone-vault](https://docs.drone.io/configure/secrets/external/vault/) | 1.3.0 | Drone plugin for integrating with the Vault secrets manager |
|  | `electron_11` | [electron](https://github.com/electron/electron) | 11.5.0 | Cross platform desktop application shell |
|  | `etherguard` | [etherguard](https://github.com/KusakabeShi/EtherGuard-VPN) | unstable-2024-01-12 | Layer2 version of wireguard with Floyd Warshall implement in go |
|  | `fastapi-dls` | [fastapi-dls](https://gitea.publichub.eu/oscar.krause/fastapi-dls) | unstable-2024-10-24 | Minimal Delegated License Service (DLS) |
|  | `fcitx5-breeze` | [fcitx5-breeze](https://github.com/scratch-er/fcitx5-breeze) | 3.1.0 | Fcitx5 theme to match KDE's Breeze style |
|  | `flasgger` | [flasgger](http://flasgger.pythonanywhere.com/) | 0.9.5 | Easy OpenAPI specs and Swagger UI for your Flask API |
|  | `ftp-proxy` | [ftp-proxy](http://www.ftpproxy.org/) | 1.2.3 | FTP Proxy Server |
|  | `genshin-checkin-helper` | [genshin-checkin-helper](https://gitlab.com/y1ndan/genshin-checkin-helper) | unstable-2021-11-09 | More than check-in for Genshin Impact |
|  | `genshinhelper2` | [genshinhelper2](https://gitlab.com/y1ndan/genshinhelper2) | unstable-2023-05-22 | Python library for miHoYo bbs and HoYoLAB Community |
|  | `glauth` | [glauth](https://github.com/glauth/glauth) | 2.3.2 | Lightweight LDAP server for development, home use, or CI |
| `x86_64-linux` | `google-earth-pro` | [google-earth-pro](https://www.google.com/earth/) | 7.3.6.9796 | World sphere viewer |
|  | `gopherus` | [gopherus](http://gopherus.sourceforge.net/) | 1.2.2 | Gopherus is a free, multiplatform, console-mode gopher client that provides a classic text interface to the gopherspace |
|  | `grasscutter` | [grasscutter](https://github.com/Grasscutters/Grasscutter) | 1.7.4 | Server software reimplementation for a certain anime game |
|  | `hath` | [hath](https://e-hentai.org/) | 1.6.2 | Hentai@Home |
|  | `helium-gateway-rs` | [helium-gateway-rs](https://github.com/helium/gateway-rs) | unstable-2024-08-01 | Helium Gateway |
|  | `hesuvi-hrir` | [hesuvi-hrir](https://sourceforge.net/projects/hesuvi/) | 2.0.0.1 | Headphone Surround Virtualizations for Equalizer APO |
|  | `hi3-ii-martian-font` | [hi3-ii-martian-font](https://github.com/Wenti-D/HI3IIMartianFont) | unstable-2023-10-12 | Font for Martian in Honkai Impact 3rd |
|  | `hoyo-glyphs` | [hoyo-glyphs](https://github.com/SpeedyOrc-C/Hoyo-Glyphs) | 20241027 | Constructed scripts by Hoyoverse 米哈游的架空文字 |
| `x86_64-linux` | `i915-sriov` | [i915-sriov](https://github.com/strongtz/i915-sriov-dkms) | unstable-2024-10-04 | DKMS module of Linux i915 driver with SR-IOV support |
|  | `imewlconverter` | [imewlconverter](https://github.com/studyzy/imewlconverter) | 3.1.1 | ”深蓝词库转换“ 一款开源免费的输入法词库转换程序 |
| `x86_64-linux` | `inter-knot` | [inter-knot](https://inot.top) | 2.16.9+36 | 绳网是一个游戏、技术交流平台 |
|  | `jproxy` | [jproxy](https://github.com/LuckyPuppy514/jproxy) | 3.4.1 | Proxy between Sonarr / Radarr and Jackett / Prowlarr, mainly used to optimize search and improve recognition rate |
|  | `kaixinsong-fonts` | [kaixinsong-fonts](http://www.guoxuedashi.net/zidian/bujian/KaiXinSong.php) | 3.0 | KaiXinSong |
|  | `kata-image` | [kata-image](https://github.com/kata-containers/kata-containers) | 3.10.1 | Kata Containers is an open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs. (Packaging script adapted from https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-images/default.nix) |
|  | `kata-runtime` | [kata-runtime](https://github.com/kata-containers/kata-containers) | 3.10.1 | Kata Containers is an open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs. (Packaging script adapted from https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-runtime/default.nix) |
|  | `kikoplay` | [kikoplay](https://kikoplay.fun) | 1.0.3 | KikoPlay - NOT ONLY A Full-Featured Danmu Player 不仅仅是全功能弹幕播放器 |
|  | `konnect` | [konnect](https://github.com/Kopano-dev/konnect) | 0.34.0 | Kopano Konnect implements an OpenID provider (OP) with integrated web login and consent forms |
|  | `ldap-auth-proxy` | [ldap-auth-proxy](https://github.com/pinepain/ldap-auth-proxy) | unstable-2020-07-29 | Simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend |
|  | `libnftnl-fullcone` | [libnftnl](https://netfilter.org/projects/libnftnl/) | 1.2.8 | Userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem |
|  | `liboqs` | [liboqs](https://openquantumsafe.org) | 0.11.0 | C library for prototyping and experimenting with quantum-resistant cryptography |
|  | `liboqs-unstable` | [liboqs](https://openquantumsafe.org) | unstable-2024-11-05 | C library for prototyping and experimenting with quantum-resistant cryptography |
| `x86_64-linux` | `libqcef` | [libqcef](https://github.com/martyr-deepin/libqcef) | unstable-2019-11-23 | Qt5 binding of CEF |
|  | `lyrica` | [lyrica](https://github.com/chiyuki0325/lyrica) | 0.12 | Linux desktop lyrics widget focused on simplicity and integration |
|  | `lyrica-plasmoid` | [lyrica](https://github.com/chiyuki0325/lyrica) | 0.12 | Linux desktop lyrics widget focused on simplicity and integration (Plasmoid component) |
|  | `magiskboot` | [magiskboot](https://topjohnwu.github.io/Magisk/tools.html) | 28.0 | Tool to unpack / repack boot images, parse / patch / extract cpio, patch dtb, hex patch binaries, and compress / decompress files with multiple algorithms |
|  | `mtkclient` | [mtkclient](https://github.com/bkerler/mtkclient) | 2.0.1.freeze | MTK reverse engineering and flash tool |
|  | `ncmdump-rs` | [ncmdump-rs](https://github.com/iqiziqi/ncmdump.rs) | 0.8.0 | NetEase Cloud Music copyright protection file dump by rust |
|  | `netboot-xyz` | [netboot-xyz](https://netboot.xyz/) | 2.0.82 | Your favorite operating systems in one place. A network-based bootable operating system installer based on iPXE |
| `x86_64-linux` | `netease-cloud-music` | [netease-cloud-music](https://music.163.com) | 1.2.1 | NetEase Cloud Music Linux Client (package script adapted from NixOS-CN and Freed-Wu) |
|  | `netns-exec` | [netns-exec](https://github.com/pekman/netns-exec) | unstable-2016-07-30 | Run command in Linux network namespace as normal user |
|  | `nft-fullcone` | [nft-fullcone](https://github.com/fullcone-nat-nftables/nft-fullcone) | unstable-2023-05-17 | Nftables fullcone expression kernel module |
|  | `nftables-fullcone` | [nftables](https://netfilter.org/projects/nftables/) | 1.1.1 | Project that aims to replace the existing {ip,ip6,arp,eb}tables framework |
|  | `noise-suppression-for-voice` | [noise-suppression-for-voice](https://github.com/werman/noise-suppression-for-voice) | 1.10 | Noise suppression plugin based on Xiph's RNNoise |
|  | `nullfs` | [nullfs](https://github.com/xrgtn/nullfs) | unstable-2016-01-28 | FUSE nullfs drivers |
|  | `nullfsvfs` | [nullfsvfs](https://github.com/abbbi/nullfsvfs) | 0.17 | Virtual black hole file system that behaves like /dev/null |
|  | `nvlax` | [nvlax](https://github.com/illnyang/nvlax) | unstable-2021-10-29 | Future-proof NvENC & NvFBC patcher |
|  | `nvlax-530` | [nvlax](https://github.com/illnyang/nvlax) | unstable-2021-10-29 | Future-proof NvENC & NvFBC patcher (for NVIDIA driver >= 530) |
|  | `oci-arm-host-capacity` | [oci-arm-host-capacity](https://github.com/hitrov/oci-arm-host-capacity) | unstable-2024-08-13 | This script allows to bypass Oracle Cloud Infrastructure 'Out of host capacity' error immediately when additional OCI capacity will appear in your Home Region / Availability domain |
|  | `onepush` | [onepush](https://gitlab.com/y1ndan/onepush) | unstable-2023-11-28 | Python library to send notifications to your iPhone, Discord, Telegram, WeChat, QQ and DingTalk |
|  | `openssl-oqs-provider` | [openssl-oqs-provider](https://openquantumsafe.org) | 0.7.0 | OpenSSL 3 provider containing post-quantum algorithms |
|  | `openvswitch-dpdk` | [openvswitch-dpdk](https://www.openvswitch.org/) | 3.4.0 | Multilayer virtual switch |
|  | `osdlyrics` | [osdlyrics](https://github.com/osdlyrics/osdlyrics) | 0.5.15 | Standalone lyrics fetcher/displayer (windowed and OSD mode) |
|  | `ovpn-dco` | [ovpn-dco](https://github.com/OpenVPN/ovpn-dco) | unstable-2024-07-12 | OpenVPN Data Channel Offload in the linux kernel |
|  | `palworld-exporter` | [palworld-exporter](https://github.com/palworldlol/palworld-exporter) | 1.3.1 | Prometheus exporter for Palword Server |
|  | `palworld-worldoptions` | [palworld-worldoptions](https://github.com/legoduded/palworld-worldoptions) | 1.10.0 | Tool for creating WorldOption.sav and applying the PalWorldSettings.ini for dedicated servers |
|  | `payload-dumper-go` | [payload-dumper-go](https://github.com/ssut/payload-dumper-go) | 1.2.2 | Android OTA payload dumper written in Go |
|  | `peerbanhelper` | [peerbanhelper](https://github.com/Ghost-chu/PeerBanHelper) | 7.1.1 | 自动封禁不受欢迎、吸血和异常的 BT 客户端，并支持自定义规则。PeerId黑名单/UserAgent黑名单/IP CIDR/假进度检测/超量下载检测/主动探测 支持 qBittorrent/Transmission |
|  | `phpmyadmin` | [phpmyadmin](https://www.phpmyadmin.net/) | 5.2.1 | Web interface for MySQL and MariaDB |
|  | `phppgadmin` | [phppgadmin](https://github.com/phppgadmin/phppgadmin) | 7.14.7-mod | Premier web-based administration tool for PostgreSQL |
|  | `plasma-panel-transparency-toggle` | [plasma-panel-transparency-toggle](https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6) | unstable-2024-04-17 | Rewrite of [Panel Transparency Button](https://github.com/psifidotos/paneltransparencybutton) for plasma 6 |
|  | `plasma-smart-video-wallpaper-reborn` | [plasma-smart-video-wallpaper-reborn](https://store.kde.org/p/2139746) | 0.4.1 | Plasma 6 wallpaper plugin to play videos on your Desktop/Lock Screen |
|  | `plasma-yesplaymusic-lyric` | [plasma-yesplaymusic-lyric](https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics) | unstable-2024-08-10 | Display YesPlayMusic lyrics on the plasma panel | 在KDE plasma面板中显示YesPlayMusic的歌词 |
| `x86_64-linux` | `pocl` | [pocl](http://portablecl.org) | 6.0 | Portable open source (MIT-licensed) implementation of the OpenCL standard |
|  | `procps4` | [procps4](https://gitlab.com/procps-ng/procps) | 4.0.4 | Utilities that give information about processes using the /proc filesystem |
|  | `pterodactyl-wings` | [pterodactyl-wings](https://pterodactyl.io) | 1.11.13 | Server control plane for Pterodactyl Panel |
|  | `py-rcon` | [py-rcon](https://github.com/ttk1/py-rcon) | 1.3.0 | Python implementation of RCON |
|  | `qemu-user-static` | [qemu-user-static](http://www.qemu.org/) | 9.1.1+ds-2 | Generic and open source machine emulator and virtualizer |
|  | `qhttpengine` | [qhttpengine](https://github.com/nitroshare/qhttpengine) | unstable-2018-03-22 | HTTP server for Qt applications |
|  | `qq` | [qq](https://im.qq.com/linuxqq/index.html) | 3.2.13 | QQ for Linux |
| `x86_64-linux` | `qqmusic` | [qqmusic](https://y.qq.com/) | 1.1.7 | Tencent QQ Music |
|  | `qqsp` | [qqsp](https://github.com/Sonnix1/Qqsp) | 1.9 | QT Quest Soft Player is a interactive fiction stories and games player (compatible fork of qsp.su) |
|  | `qsp` | [qsp](https://github.com/QSPFoundation/qspgui) | 5.9.0-b11 | QSP is an Interactive Fiction development platform (GUI application) |
|  | `qsp-lib` | [qsp-lib](https://github.com/QSPFoundation/qsp) | unstable-2024-10-29 | QSP is an Interactive Fiction development platform (Game Library) |
|  | `r8125` | [r8125](https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software) | 9.013.02-2 | Linux device driver for Realtek 2.5/5 Gigabit Ethernet controllers with PCI-Express interface |
|  | `r8168` | [r8168](https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software) | 8.054.00 | Linux device driver for Realtek Ethernet controllers |
|  | `rime-aurora-pinyin` | [rime-aurora-pinyin](https://github.com/hosxy/rime-aurora-pinyin) | unstable-2022-08-28 | 【极光拼音】输入方案 |
|  | `rime-custom-pinyin-dictionary` | [rime-custom-pinyin-dictionary](https://github.com/wuhgit/CustomPinyinDictionary) | 20240824 | 自建拼音输入法词库，百万常用词汇量，适配 Fcitx5 (Linux / Android) 及 Gboard (Android + Magisk or KernelSU) 。 |
|  | `rime-dict` | [rime-dict](https://github.com/Iorest/rime-dict) | unstable-2020-12-26 | RIME 词库增强 |
|  | `rime-ice` | [rime-ice](https://dvel.me/posts/rime-ice/) | unstable-2024-11-04 | Rime 配置：雾凇拼音 | 长期维护的简体词库 |
|  | `rime-moegirl` | [rime-moegirl](https://github.com/outloudvi/mw2fcitx/releases) | 20241009 | Releases for dict of zh.moegirl.org.cn |
|  | `rime-zhwiki` | [rime-zhwiki](https://github.com/felixonmars/fcitx5-pinyin-zhwiki) | 20240426 | Fcitx 5 Pinyin Dictionary from zh.wikipedia.org |
|  | `route-chain` | [route-chain](https://github.com/xddxdd/route-chain) | unstable-2023-09-09 | Small app to generate a long path in traceroute |
|  | `runpod-python` | [runpod-python](https://github.com/runpod/runpod-python) | 1.7.4 | Python library for RunPod API and serverless worker SDK |
|  | `runpodctl` | [runpodctl](https://www.runpod.io) | 1.14.4 | RunPod CLI for pod management |
|  | `sam-toki-mouse-cursors` | [sam-toki-mouse-cursors](https://github.com/SamToki/IconDesign---Sam-Toki-Mouse-Cursors) | 7.00 | Original mouse cursors (pointers) for Windows, with minimalistic design |
| `x86_64-linux` | `sgx-software-enable` | [sgx-software-enable](https://github.com/intel/sgx-software-enable) | unstable-2023-01-06 | This application will enable Intel SGX on Linux systems where the BIOS supports Intel SGX, but does not provide an explicit option to enable it. These systems can only enable Intel SGX via the "software enable" procedure |
|  | `smartrent_py` | [smartrent_py](https://github.com/ZacheryThomas/smartrent.py) | 0.4.0 | Api for SmartRent locks, thermostats, moisture sensors and switches |
|  | `smfc` | [smfc](https://github.com/petersulyok/smfc) | 3.5.1 | Super Micro Fan Control |
|  | `soggy` | [soggy](https://github.com/LDAsuku/soggy) | unstable-2022-12-14 | Experimental server emulator for a game I forgot its name |
|  | `space-cadet-pinball-full-tilt` | [SpaceCadetPinball](https://github.com/k4zmu2a/SpaceCadetPinball) | 2.1.0 | Reverse engineering of 3D Pinball for Windows – Space Cadet, a game bundled with Windows (With Full Tilt Pinball data) |
|  | `suwayomi-server` | [suwayomi-server](https://github.com/Suwayomi/Suwayomi-Server) | 1.1.1-r1535 | Rewrite of Tachiyomi for the Desktop |
| `x86_64-linux` | `svp` | [svp](https://www.svp-team.com/wiki/SVP:Linux) | 4.6.263 | SmoothVideo Project 4 (SVP4) converts any video to 60 fps (and even higher) and performs this in real time right in your favorite video player |
| `x86_64-linux` | `svp-mpv` | [mpv-with-scripts-0.39.0](https://mpv.io) |  | General-purpose media player, fork of MPlayer and mplayer2 |
|  | `sx1302-hal` | [sx1302-hal](https://github.com/NebraLtd/sx1302_hal) | unstable-2023-02-06 | SX1302/SX1303 Hardware Abstraction Layer and Tools (packet forwarder...) |
|  | `tqdm-loggable` | [tqdm-loggable](https://pypi.org/project/tqdm-loggable/) | 0.2 | TQDM progress bar helpers for logging and other headless application |
|  | `uesave` | [uesave](https://github.com/trumank/uesave-rs) | 0.5.0 | Library for reading and writing Unreal Engine save files (commonly referred to as GVAS) |
|  | `uesave-0_3_0` | [uesave](https://github.com/trumank/uesave-rs) | 0.3.0 | Library for reading and writing Unreal Engine save files (commonly referred to as GVAS). Older version that works with Palworld |
|  | `uksmd` | [uksmd](https://github.com/CachyOS/uksmd) | 1.2.11 | Userspace KSM helper daemon |
| `x86_64-linux` | `unigine-heaven` | [unigine-heaven](https://benchmark.unigine.com/heaven) | 4.0 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-sanctuary` | [unigine-sanctuary](https://benchmark.unigine.com/sanctuary) | 2.3 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-superposition` | [unigine-superposition](https://benchmark.unigine.com/superposition) | 1.1 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-tropics` | [unigine-tropics](https://benchmark.unigine.com/tropics) | 1.3 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
| `x86_64-linux` | `unigine-valley` | [unigine-valley](https://benchmark.unigine.com/valley) | 1.0 | Extreme performance and stability test for PC hardware: video card, power supply, cooling system |
|  | `vbmeta-disable-verification` | [vbmeta-disable-verification](https://github.com/libxzr/vbmeta-disable-verification) | 1.0 | Patch Android vbmeta image and disable verification flags inside |
|  | `vgpu-unlock-rs` | [vgpu-unlock-rs](https://github.com/mbilker/vgpu_unlock-rs) | 2.5.0 | Unlock vGPU functionality for consumer grade GPUs |
|  | `vk-hdr-layer` | [vk-hdr-layer](https://github.com/Zamundaaa/VK_hdr_layer) | unstable-2024-10-19 | Vulkan layer utilizing a small color management / HDR protocol for experimentation |
|  | `vpp` | [vpp](https://wiki.fd.io/view/VPP/What_is_VPP%3F) | 24.10 | Vector Packet Processing |
| `x86_64-linux` | `wechat-uos` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `x86_64-linux` | `wechat-uos-bin` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `x86_64-linux` | `wechat-uos-without-sandbox` | [wechat-uos](https://weixin.qq.com/) | 4.0.0.21 | WeChat desktop without sandbox (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap) |
| `x86_64-linux` | `wine-wechat` | [wine-wechat](https://weixin.qq.com/) | 3.9.12.17 | Wine WeChat x64 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat) |
| `x86_64-linux` | `wine-wechat-x86` | [wine-wechat-x86](https://weixin.qq.com/) | 3.9.12.16 | Wine WeChat x86 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat) |
|  | `xstatic-asciinema-player` | [xstatic-asciinema-player](https://github.com/asciinema/asciinema-player) | 2.6.1.1 | Asciinema-player packaged for setuptools (easy_install) / pip |
|  | `xstatic-font-awesome` | [xstatic-font-awesome](https://github.com/FortAwesome/Font-Awesome) | 4.7.0.0 | Font Awesome packaged for setuptools (easy_install) / pip |
</details>


<details>
<summary>Package set: asteriskDigiumCodecs (70 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `asteriskDigiumCodecs.10.g729a` | [asterisk-10-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.5 | Asterisk 10 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.10.silk` | [asterisk-10-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.0 | Asterisk 10 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.10.siren14` | [asterisk-10-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk 10 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.10.siren7` | [asterisk-10-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk 10 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.g729a` | [asterisk-11-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk 11 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.silk` | [asterisk-11-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 11 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.siren14` | [asterisk-11-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 11 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.11.siren7` | [asterisk-11-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 11 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.g729a` | [asterisk-12-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.7 | Asterisk 12 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.silk` | [asterisk-12-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 12 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.siren14` | [asterisk-12-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk 12 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.12.siren7` | [asterisk-12-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk 12 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.g729a` | [asterisk-13-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk 13 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.opus` | [asterisk-13-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 13 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.silk` | [asterisk-13-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 13 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.siren14` | [asterisk-13-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 13 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.13.siren7` | [asterisk-13-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 13 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.g729a` | [asterisk-14-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk 14 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.opus` | [asterisk-14-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 14 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.silk` | [asterisk-14-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 14 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.siren14` | [asterisk-14-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 14 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.14.siren7` | [asterisk-14-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 14 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.g729a` | [asterisk-15-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk 15 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.opus` | [asterisk-15-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 15 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.silk` | [asterisk-15-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 15 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.siren14` | [asterisk-15-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 15 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.15.siren7` | [asterisk-15-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 15 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.g729a` | [asterisk-16-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk 16 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.opus` | [asterisk-16-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 16 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.silk` | [asterisk-16-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 16 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.siren14` | [asterisk-16-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 16 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.16.siren7` | [asterisk-16-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 16 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.g729a` | [asterisk-17-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.9 | Asterisk 17 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.opus` | [asterisk-17-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 17 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.silk` | [asterisk-17-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 17 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.siren14` | [asterisk-17-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 17 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.17.siren7` | [asterisk-17-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 17 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.g729a` | [asterisk-18-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk 18 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.opus` | [asterisk-18-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 18 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.silk` | [asterisk-18-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 18 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.siren14` | [asterisk-18-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 18 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.18.siren7` | [asterisk-18-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 18 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.g729a` | [asterisk-19-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk 19 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.opus` | [asterisk-19-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 19 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.silk` | [asterisk-19-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 19 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.siren14` | [asterisk-19-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 19 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.19.siren7` | [asterisk-19-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 19 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_4.g729a` | [asterisk-1.4-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.5 | Asterisk 1.4 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_6_2_0.g729a` | [asterisk-1.6.2.0-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.5 | Asterisk 1.6.2.0 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_6_2_0.siren14` | [asterisk-1.6.2.0-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk 1.6.2.0 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_6_2_0.siren7` | [asterisk-1.6.2.0-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk 1.6.2.0 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_0.g729a` | [asterisk-1.8.0-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.6 | Asterisk 1.8.0 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_0.siren14` | [asterisk-1.8.0-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.5 | Asterisk 1.8.0 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_0.siren7` | [asterisk-1.8.0-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.5 | Asterisk 1.8.0 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.1_8_4.g729a` | [asterisk-1.8.4-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.8 | Asterisk 1.8.4 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.g729a` | [asterisk-20-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk 20 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.opus` | [asterisk-20-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 20 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.silk` | [asterisk-20-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 20 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.siren14` | [asterisk-20-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 20 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.20.siren7` | [asterisk-20-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 20 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.g729a` | [asterisk-21-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk 21 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.opus` | [asterisk-21-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 21 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.silk` | [asterisk-21-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 21 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.siren14` | [asterisk-21-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 21 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.21.siren7` | [asterisk-21-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 21 siren7 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.g729a` | [asterisk-22-codec-g729a](https://downloads.digium.com/pub/telephony/codec_g729a/) | 3.1.10 | Asterisk 22 g729a Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.opus` | [asterisk-22-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | Asterisk 22 opus Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.silk` | [asterisk-22-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | Asterisk 22 silk Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.siren14` | [asterisk-22-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | Asterisk 22 siren14 Codec by Digium |
| `x86_64-linux` | `asteriskDigiumCodecs.22.siren7` | [asterisk-22-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | Asterisk 22 siren7 Codec by Digium |
</details>

<details>
<summary>Package set: lantianCustomized (11 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `lantianCustomized.asterisk` | [asterisk](https://www.asterisk.org/) | 20.9.3 | Asterisk with Lan Tian modifications |
|  | `lantianCustomized.attic-telnyx-compatible` | [attic](https://github.com/zhaofengli/attic) | 0-unstable-2024-10-06 | Multi-tenant Nix Binary Cache |
|  | `lantianCustomized.coredns` | [coredns](https://github.com/xddxdd/coredns) | 1.11.3 | CoreDNS with Lan Tian's modifications |
|  | `lantianCustomized.firefox-icon-mikozilla-fireyae` | [firefox-icon-mikozilla-fireyae](https://www.reddit.com/r/Genshin_Impact/comments/x73g4p/mikozilla_fireyae/) |  | Custom icon "Mikozilla Fireyae" for Firefox |
|  | `lantianCustomized.librime-with-plugins` | [librime](https://rime.im/) | 1.11.2 | Librime with plugins (librime-charcode, librime-lua, librime-octagram, librime-proto) |
|  | `lantianCustomized.llama-cpp` | [llama-cpp](https://github.com/ggerganov/llama.cpp/) | 4038 | Inference of Meta's LLaMA model (and others) in pure C/C++ |
|  | `lantianCustomized.materialgram` | [materialgram](https://kukuruzka165.github.io/materialgram/) | 5.7.0.1 | Telegram Desktop fork with material icons and some improvements (Without anti-features) |
|  | `lantianCustomized.nbfc-linux` | [nbfc-linux-lantian](https://github.com/xddxdd/nbfc-linux) | unstable-2022-06-13 | NoteBook FanControl ported to Linux (with Lan Tian's modifications) |
|  | `lantianCustomized.nginx` | [nginx-lantian](https://openresty.org) | unstable-2024-11-05 | OpenResty with Lan Tian modifications |
|  | `lantianCustomized.telegram-desktop` | [telegram-desktop](https://desktop.telegram.org/) | 5.7.1 | Telegram Desktop messaging app (Without anti-features) |
|  | `lantianCustomized.transmission-with-webui` | [transmission](https://www.transmissionbt.com/) | 4.0.6 | Fast, easy and free BitTorrent client |
</details>

<details>
<summary>Package set: lantianLinuxXanmod (120 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `lantianLinuxXanmod.generic` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.generic-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.generic-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.generic-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-generic` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.latest-generic-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-generic-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.latest-generic-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v1` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.latest-x86_64-v1-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v1-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.latest-x86_64-v1-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v2` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.latest-x86_64-v2-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v2-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.latest-x86_64-v2-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v3` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.latest-x86_64-v3-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v3-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.latest-x86_64-v3-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v4` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.latest-x86_64-v4-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.latest-x86_64-v4-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.latest-x86_64-v4-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-generic` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.lts-generic-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-generic-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.lts-generic-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v1` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.lts-x86_64-v1-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v1-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.lts-x86_64-v1-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v2` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.lts-x86_64-v2-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v2-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.lts-x86_64-v2-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v3` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.lts-x86_64-v3-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v3-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.lts-x86_64-v3-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v4` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.lts-x86_64-v4-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.lts-x86_64-v4-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.lts-x86_64-v4-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-generic` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-generic-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-generic-lto` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-generic-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1-lto` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v1-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2-lto` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v2-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3-lto` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v3-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4-lto` | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_0-x86_64-v4-lto-configfile` | linux-config | 6.0.12-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-generic` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-generic-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-generic-lto` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-generic-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1-lto` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v1-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2-lto` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v2-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3-lto` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v3-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4-lto` | [linux](https://www.kernel.org/) | 6.1.77-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_1-x86_64-v4-lto-configfile` | linux-config | 6.1.77-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-generic` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-generic-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-generic-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-generic-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v1-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v2-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v3-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4-lto` | [linux](https://www.kernel.org/) | 6.6.59-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.v6_6-x86_64-v4-lto-configfile` | linux-config | 6.6.59-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v1` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.x86_64-v1-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v1-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.x86_64-v1-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v2` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.x86_64-v2-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v2-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.x86_64-v2-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v3` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.x86_64-v3-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v3-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.x86_64-v3-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v4` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications |
|  | `lantianLinuxXanmod.x86_64-v4-configfile` | linux-config | 6.11.6-xanmod1 |  |
|  | `lantianLinuxXanmod.x86_64-v4-lto` | [linux](https://www.kernel.org/) | 6.11.6-xanmod1 | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | `lantianLinuxXanmod.x86_64-v4-lto-configfile` | linux-config | 6.11.6-xanmod1 |  |
</details>

<details>
<summary>Package set: lantianLinuxXanmodPackages (0 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |

</details>

<details>
<summary>Package set: lantianPersonal (1 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `lantianPersonal.libltnginx` | [libltnginx](https://github.com/xddxdd/libltnginx) | unstable-2021-10-02 | Libltnginx |
</details>

<details>
<summary>Package set: nvidia-grid (128 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
| `x86_64-linux` | `nvidia-grid.grid.11_8` | [nvidia-x11-450.191.01-6.6.59](https://www.nvidia.com/object/unix.html) | 450.191.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.12_4` | [nvidia-x11-460.106.00-6.6.59](https://www.nvidia.com/object/unix.html) | 460.106.00 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_0` | [nvidia-x11-470.63.01-6.6.59](https://www.nvidia.com/object/unix.html) | 470.63.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_12` | [nvidia-x11-470.256.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_3` | [nvidia-x11-470.129.06-6.6.59](https://www.nvidia.com/object/unix.html) | 470.129.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_4` | [nvidia-x11-470.141.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.141.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_5` | [nvidia-x11-470.161.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_6` | [nvidia-x11-470.161.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_7` | [nvidia-x11-470.182.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.182.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.13_9` | [nvidia-x11-470.223.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_0` | [nvidia-x11-510.47.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_1` | [nvidia-x11-510.73.08-6.6.59](https://www.nvidia.com/object/unix.html) | 510.73.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_2` | [nvidia-x11-510.85.02-6.6.59](https://www.nvidia.com/object/unix.html) | 510.85.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_3` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.14_4` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_0` | [nvidia-x11-525.60.13-6.6.59](https://www.nvidia.com/object/unix.html) | 525.60.13 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_1` | [nvidia-x11-525.85.05-6.6.59](https://www.nvidia.com/object/unix.html) | 525.85.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_2` | [nvidia-x11-525.105.17-6.6.59](https://www.nvidia.com/object/unix.html) | 525.105.17 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.15_3` | [nvidia-x11-525.125.06-6.6.59](https://www.nvidia.com/object/unix.html) | 525.125.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_0` | [nvidia-x11-535.54.03-6.6.59](https://www.nvidia.com/object/unix.html) | 535.54.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_1` | [nvidia-x11-535.104.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.104.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_2` | [nvidia-x11-535.129.03-6.6.59](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_3` | [nvidia-x11-535.154.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.154.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_4` | [nvidia-x11-535.161.07-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_5` | [nvidia-x11-535.161.08-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_6` | [nvidia-x11-535.183.01-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.16_7` | [nvidia-x11-535.183.06-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_0` | [nvidia-x11-550.54.14-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.14 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_1` | [nvidia-x11-550.54.15-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.15 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_2` | [nvidia-x11-550.90.07-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.17_3` | [nvidia-x11-550.90.07-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.grid.9_2` | [nvidia-x11-430.63-6.6.59](https://www.nvidia.com/object/unix.html) | 430.63 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.11_8` | [nvidia-x11-450.191.01-6.6.59](https://www.nvidia.com/object/unix.html) | 450.191.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.12_4` | [nvidia-x11-460.106.00-6.6.59](https://www.nvidia.com/object/unix.html) | 460.106.00 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_0` | [nvidia-x11-470.63.01-6.6.59](https://www.nvidia.com/object/unix.html) | 470.63.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_12` | [nvidia-x11-470.256.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_3` | [nvidia-x11-470.129.06-6.6.59](https://www.nvidia.com/object/unix.html) | 470.129.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_4` | [nvidia-x11-470.141.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.141.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_5` | [nvidia-x11-470.161.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_6` | [nvidia-x11-470.161.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_7` | [nvidia-x11-470.182.03-6.6.59](https://www.nvidia.com/object/unix.html) | 470.182.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.13_9` | [nvidia-x11-470.223.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_0` | [nvidia-x11-510.47.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_1` | [nvidia-x11-510.73.08-6.6.59](https://www.nvidia.com/object/unix.html) | 510.73.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_2` | [nvidia-x11-510.85.02-6.6.59](https://www.nvidia.com/object/unix.html) | 510.85.02 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_3` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.14_4` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_0` | [nvidia-x11-525.60.13-6.6.59](https://www.nvidia.com/object/unix.html) | 525.60.13 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_1` | [nvidia-x11-525.85.05-6.6.59](https://www.nvidia.com/object/unix.html) | 525.85.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_2` | [nvidia-x11-525.105.17-6.6.59](https://www.nvidia.com/object/unix.html) | 525.105.17 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.15_3` | [nvidia-x11-525.125.06-6.6.59](https://www.nvidia.com/object/unix.html) | 525.125.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_0` | [nvidia-x11-535.54.03-6.6.59](https://www.nvidia.com/object/unix.html) | 535.54.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_1` | [nvidia-x11-535.104.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.104.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_2` | [nvidia-x11-535.129.03-6.6.59](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_3` | [nvidia-x11-535.154.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.154.05 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_4` | [nvidia-x11-535.161.07-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_5` | [nvidia-x11-535.161.08-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.08 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_6` | [nvidia-x11-535.183.01-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.01 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.16_7` | [nvidia-x11-535.183.06-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.06 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_0` | [nvidia-x11-550.54.14-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.14 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_1` | [nvidia-x11-550.54.15-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.15 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_2` | [nvidia-x11-550.90.07-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.17_3` | [nvidia-x11-550.90.07-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.07 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.guest.9_2` | [nvidia-x11-430.63-6.6.59](https://www.nvidia.com/object/unix.html) | 430.63 | NVIDIA vGPU guest driver (GRID driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.11_8` | [nvidia-x11-450.191-6.6.59](https://www.nvidia.com/object/unix.html) | 450.191 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.12_4` | [nvidia-x11-460.107-6.6.59](https://www.nvidia.com/object/unix.html) | 460.107 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_0` | [nvidia-x11-470.63-6.6.59](https://www.nvidia.com/object/unix.html) | 470.63 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_12` | [nvidia-x11-470.256.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_3` | [nvidia-x11-470.129.04-6.6.59](https://www.nvidia.com/object/unix.html) | 470.129.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_4` | [nvidia-x11-470.141.05-6.6.59](https://www.nvidia.com/object/unix.html) | 470.141.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_5` | [nvidia-x11-470.161.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_6` | [nvidia-x11-470.161.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_7` | [nvidia-x11-470.182.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.182.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.13_9` | [nvidia-x11-470.223.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_0` | [nvidia-x11-510.47.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_1` | [nvidia-x11-510.73.06-6.6.59](https://www.nvidia.com/object/unix.html) | 510.73.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_2` | [nvidia-x11-510.85.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.85.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_3` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.14_4` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_0` | [nvidia-x11-525.60.12-6.6.59](https://www.nvidia.com/object/unix.html) | 525.60.12 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_1` | [nvidia-x11-525.85.07-6.6.59](https://www.nvidia.com/object/unix.html) | 525.85.07 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_2` | [nvidia-x11-525.105.14-6.6.59](https://www.nvidia.com/object/unix.html) | 525.105.14 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.15_3` | [nvidia-x11-525.125.03-6.6.59](https://www.nvidia.com/object/unix.html) | 525.125.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_0` | [nvidia-x11-535.54.06-6.6.59](https://www.nvidia.com/object/unix.html) | 535.54.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_1` | [nvidia-x11-535.104.06-6.6.59](https://www.nvidia.com/object/unix.html) | 535.104.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_2` | [nvidia-x11-535.129.03-6.6.59](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_3` | [nvidia-x11-535.154.02-6.6.59](https://www.nvidia.com/object/unix.html) | 535.154.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_4` | [nvidia-x11-535.161.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_5` | [nvidia-x11-535.161.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_6` | [nvidia-x11-535.183.04-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.16_7` | [nvidia-x11-535.183.04-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_0` | [nvidia-x11-550.54.10-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.10 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_1` | [nvidia-x11-550.54.16-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.16 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_2` | [nvidia-x11-550.90.05-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.17_3` | [nvidia-x11-550.90.05-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.host.9_2` | [nvidia-x11-430.67-6.6.59](https://www.nvidia.com/object/unix.html) | 430.67 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.11_8` | [nvidia-x11-450.191-6.6.59](https://www.nvidia.com/object/unix.html) | 450.191 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.12_4` | [nvidia-x11-460.107-6.6.59](https://www.nvidia.com/object/unix.html) | 460.107 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_0` | [nvidia-x11-470.63-6.6.59](https://www.nvidia.com/object/unix.html) | 470.63 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_12` | [nvidia-x11-470.256.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.256.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_3` | [nvidia-x11-470.129.04-6.6.59](https://www.nvidia.com/object/unix.html) | 470.129.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_4` | [nvidia-x11-470.141.05-6.6.59](https://www.nvidia.com/object/unix.html) | 470.141.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_5` | [nvidia-x11-470.161.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_6` | [nvidia-x11-470.161.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.161.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_7` | [nvidia-x11-470.182.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.182.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.13_9` | [nvidia-x11-470.223.02-6.6.59](https://www.nvidia.com/object/unix.html) | 470.223.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_0` | [nvidia-x11-510.47.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.47.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_1` | [nvidia-x11-510.73.06-6.6.59](https://www.nvidia.com/object/unix.html) | 510.73.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_2` | [nvidia-x11-510.85.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.85.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_3` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.14_4` | [nvidia-x11-510.108.03-6.6.59](https://www.nvidia.com/object/unix.html) | 510.108.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_0` | [nvidia-x11-525.60.12-6.6.59](https://www.nvidia.com/object/unix.html) | 525.60.12 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_1` | [nvidia-x11-525.85.07-6.6.59](https://www.nvidia.com/object/unix.html) | 525.85.07 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_2` | [nvidia-x11-525.105.14-6.6.59](https://www.nvidia.com/object/unix.html) | 525.105.14 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.15_3` | [nvidia-x11-525.125.03-6.6.59](https://www.nvidia.com/object/unix.html) | 525.125.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_0` | [nvidia-x11-535.54.06-6.6.59](https://www.nvidia.com/object/unix.html) | 535.54.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_1` | [nvidia-x11-535.104.06-6.6.59](https://www.nvidia.com/object/unix.html) | 535.104.06 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_2` | [nvidia-x11-535.129.03-6.6.59](https://www.nvidia.com/object/unix.html) | 535.129.03 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_3` | [nvidia-x11-535.154.02-6.6.59](https://www.nvidia.com/object/unix.html) | 535.154.02 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_4` | [nvidia-x11-535.161.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_5` | [nvidia-x11-535.161.05-6.6.59](https://www.nvidia.com/object/unix.html) | 535.161.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_6` | [nvidia-x11-535.183.04-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.16_7` | [nvidia-x11-535.183.04-6.6.59](https://www.nvidia.com/object/unix.html) | 535.183.04 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_0` | [nvidia-x11-550.54.10-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.10 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_1` | [nvidia-x11-550.54.16-6.6.59](https://www.nvidia.com/object/unix.html) | 550.54.16 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_2` | [nvidia-x11-550.90.05-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.17_3` | [nvidia-x11-550.90.05-6.6.59](https://www.nvidia.com/object/unix.html) | 550.90.05 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
| `x86_64-linux` | `nvidia-grid.vgpu.9_2` | [nvidia-x11-430.67-6.6.59](https://www.nvidia.com/object/unix.html) | 430.67 | NVIDIA vGPU host driver (vGPU-KVM driver, experimental package) |
</details>

<details>
<summary>Package set: openj9-ibm-semeru (148 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `openj9-ibm-semeru.jdk-bin-11` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.24.1 | OpenJ9 binaries built by IBM Semeru |
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
|  | `openj9-ibm-semeru.jdk-bin-16` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-16_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_10_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.10.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_11_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.11.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_12_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-17_0_12_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.1 | OpenJ9 binaries built by IBM Semeru |
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
|  | `openj9-ibm-semeru.jdk-bin-21` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_3_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.3.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_4_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-21_0_4_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22_0_1_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22_0_2_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-22_0_2_1` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-23` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-23_0_0_0` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jdk-bin-8` | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.422.1 | OpenJ9 binaries built by IBM Semeru |
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
|  | `openj9-ibm-semeru.jre-bin-11` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.24.1 | OpenJ9 binaries built by IBM Semeru |
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
|  | `openj9-ibm-semeru.jre-bin-16` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-16_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_10_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.10.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_11_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.11.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_12_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-17_0_12_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.12.1 | OpenJ9 binaries built by IBM Semeru |
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
|  | `openj9-ibm-semeru.jre-bin-21` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_3_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.3.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_4_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-21_0_4_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 21.0.4.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22_0_1_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.1.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22_0_2_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-22_0_2_1` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 22.0.2.1 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-23` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-23_0_0_0` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 23.0.0.0 | OpenJ9 binaries built by IBM Semeru |
|  | `openj9-ibm-semeru.jre-bin-8` | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.422.1 | OpenJ9 binaries built by IBM Semeru |
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
</details>

<details>
<summary>Package set: openjdk-adoptium (112 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `openjdk-adoptium.jdk-bin-11` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.25_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_12_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.12_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_13_8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.13_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_14_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.14.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-11_0_14_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.14_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
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
|  | `openjdk-adoptium.jdk-bin-16` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 16.0.2_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-16_0_2_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 16.0.2_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.13_11_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_10_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.10_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_11_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.11_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_12_7` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.12_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-17_0_13_11` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.13_11_adopt | OpenJDK binaries built by Eclipse Adoptium |
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
|  | `openjdk-adoptium.jdk-bin-17_35` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17_35_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_0_1_10` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.1_10_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_0_2_1_1` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_0_2_9` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-18_36` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18_36_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u432-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jdk-bin-8u302_b08` | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u302-b08 | OpenJDK binaries built by Eclipse Adoptium |
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
|  | `openjdk-adoptium.jre-bin-11` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.25_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_12_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.12_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_13_8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.13_8_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_14_1_1` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.14.1_1_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-11_0_14_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.14_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
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
|  | `openjdk-adoptium.jre-bin-17` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.13_11_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_10_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.10_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_11_9` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.11_9_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_12_7` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.12_7_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-17_0_13_11` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.13_11_adopt | OpenJDK binaries built by Eclipse Adoptium |
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
|  | `openjdk-adoptium.jre-bin-8` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u432-b06_adopt | OpenJDK binaries built by Eclipse Adoptium |
|  | `openjdk-adoptium.jre-bin-8u302_b08` | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u302-b08 | OpenJDK binaries built by Eclipse Adoptium |
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
</details>

<details>
<summary>Package set: plangothic-fonts (2 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `plangothic-fonts.allideo` | [plangothic-fonts-allideo](https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic) | V1.9.5766 | Plangothic Project |
|  | `plangothic-fonts.fallback` | [plangothic-fonts-fallback](https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic) | V1.9.5766 | Plangothic Project |
</details>

<details>
<summary>Package set: th-fonts (9 packages)</summary>

| State | Path | Name | Version | Description |
| ----- | ---- | ---- | ------- | ----------- |
|  | `th-fonts.hak` | [th-hak](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-hak font |
|  | `th-fonts.joeng` | [th-joeng](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-joeng font |
|  | `th-fonts.khaai-p` | [th-khaai-p](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-khaai-p font |
|  | `th-fonts.khaai-t` | [th-khaai-t](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-khaai-t font |
|  | `th-fonts.ming` | [th-ming](http://cheonhyeong.com/Simplified/download.html) | 4.1.0 | TianHeng th-ming font |
|  | `th-fonts.sung-p` | [th-sung-p](http://cheonhyeong.com/Simplified/download.html) | 4.0.0 | TianHeng th-sung-p font |
|  | `th-fonts.sung-t` | [th-sung-t](http://cheonhyeong.com/Simplified/download.html) | 4.1.0 | TianHeng th-sung-t font |
|  | `th-fonts.sy` | [th-sy](http://cheonhyeong.com/Simplified/download.html) | 4.1.0 | TianHeng th-sy font |
|  | `th-fonts.tshyn` | [th-tshyn](http://cheonhyeong.com/Simplified/download.html) | 4.1.0 | TianHeng th-tshyn font |
</details>

