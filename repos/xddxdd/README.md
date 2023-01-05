# Lan Tian's NUR Packages

![Build and populate cache](https://github.com/xddxdd/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-xddxdd-blue.svg)](https://xddxdd.cachix.org)

## How to use

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nur-xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.flake-utils.follows = "flake-utils";
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

        # Binary cache (optional)
        ({ ... }: {
          nix.settings.substituters = [ "https://xddxdd.cachix.org" ];
          nix.settings.trusted-public-keys = [ "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=" ];
        })
      ];
    };
  };
}
```

## Binary Cache

This NUR has a binary cache. Use the following settings to access it:

```nix
{
  nix.settings.substituters = [ "https://xddxdd.cachix.org" ];
  nix.settings.trusted-public-keys = [ "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=" ];
}
```

Or, use variables from this repository in case I change them:

```nix
{
  nix.settings.substituters = [ nur.repos.xddxdd._meta.url ];
  nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.publicKey ];
}
```

## Packages

<details>
<summary>Package set: (Uncategorized) (65 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | [an-anime-game-launcher-bin](https://github.com/an-anime-team/an-anime-game-launcher) |  | `an-anime-game-launcher-bin` | (EXPERIMENTAL: Needs manual game patching) An Anime Game launcher for Linux with automatic patching fixing detection of Linux/Wine and telemetry disabling |
|  | [an-anime-game-launcher-gtk-bin](https://github.com/an-anime-team/an-anime-game-launcher-gtk) | 1.2.4 | `an-anime-game-launcher-gtk-bin` | (EXPERIMENTAL: Needs manual game patching) An Anime Game Launcher variant written on Rust, GTK4 and libadwaita, using Anime Game Core library |
|  | [asterisk-g72x](https://github.com/arkadijs/asterisk-g72x) | 3855cec2ef2667f3e9224006dbaf179575752218 | `asterisk-g72x` | G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled) |
|  | [baidupcs-go](https://github.com/qjfoidnh/BaiduPCS-Go) | v3.9.0 | `baidupcs-go` | iikira/BaiduPCS-Go 原版基础上集成了分享链接/秒传链接转存功能 |
|  | [bilibili](https://app.bilibili.com/) | 1.8.2-1 | `bilibili` | Bilibili desktop client |
|  | [bird-babel-rtt](http://bird.network.cz) | e508ca76a198f633e1720466e1084333ae8b2742 | `bird-babel-rtt` | BIRD Internet Routing Daemon |
|  | [bird-lg-go](https://github.com/xddxdd/bird-lg-go) | dba2af763431386e3f69f9a53f7c544700ef0837 | `bird-lg-go` | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
|  | [bird-lgproxy-go](https://github.com/xddxdd/bird-lg-go) | dba2af763431386e3f69f9a53f7c544700ef0837 | `bird-lgproxy-go` | BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint |
| `Broken` | [boringssl-oqs](https://openquantumsafe.org) | OQS-BoringSSL-snapshot-2022-08 | `boringssl-oqs` | Fork of BoringSSL that includes prototype quantum-resistant key exchange and authentication in the TLS handshake based on liboqs |
|  | [calibre-cops](http://blog.slucas.fr/en/oss/calibre-opds-php-server) | 1.1.3 | `calibre-cops` | Calibre OPDS (and HTML) PHP Server : web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks (epub, mobi, pdf, ...) |
|  | [chmlib](http://www.jedrea.com/chmlib) | 0.40a | `chmlib-utils` | A library for dealing with Microsoft ITSS/CHM format files |
|  | [chromium-oqs-bin](https://github.com/open-quantum-safe/oqs-demos) | 0.7.2 | `chromium-oqs-bin` | Chromium with Open Quantum Safe patches |
|  | [cloudpan189-go](https://github.com/tickstep/cloudpan189-go) | v0.1.2 | `cloudpan189-go` | 天翼云盘命令行客户端(CLI)，基于GO语言实现 |
|  | [deepspeech-gpu](https://github.com/mozilla/DeepSpeech) | 0.9.3 | `deepspeech-gpu` | Speech-to-text engine which can run in real time on devices ranging from a Raspberry Pi 4 to high power GPU servers. |
|  | [deepspeech](https://github.com/mozilla/DeepSpeech) | 0.9.3 | `deepspeech-wrappers` | Speech-to-text engine which can run in real time on devices ranging from a Raspberry Pi 4 to high power GPU servers. |
|  | [dingtalk](https://www.dingtalk.com/) | 1.4.0.20909 | `dingtalk` | 钉钉 |
|  | [dn42-pingfinder](https://git.dn42.dev/dn42/pingfinder/src/branch/master/clients) | 1.0.0 | `dn42-pingfinder` | DN42 Pingfinder |
|  | [douban-openapi-server](https://github.com/caryyu/douban-openapi-server) | c7e2a0f59ba5cfb2d10a31013547686a4afab99d | `douban-openapi-server` | A Douban API server that provides an unofficial APIs for media information gathering |
|  | [drone-vault](https://docs.drone.io/configure/secrets/external/vault/) | v1.2.0 | `drone-vault` | Drone plugin for integrating with the Vault secrets manager |
|  | [etherguard](https://github.com/KusakabeShi/EtherGuard-VPN) | 1356780d7d37ad5c44d3d25d2137be6120b8bf87 | `etherguard` | Layer2 version of wireguard with Floyd Warshall implement in go |
|  | [fcitx5-breeze](https://github.com/scratch-er/fcitx5-breeze) | 2.0.0 | `fcitx5-breeze` | Fcitx5 theme to match KDE's Breeze style |
|  | [flaresolverr](https://github.com/FlareSolverr/FlareSolverr) | v3.0.0 | `flaresolverr` | Proxy server to bypass Cloudflare protection |
|  | [flasgger](http://flasgger.pythonanywhere.com/) | 0.9.5 | `flasgger` | Easy OpenAPI specs and Swagger UI for your Flask API |
|  | [ftp-proxy](http://www.ftpproxy.org/) | 1.2.3 | `ftp-proxy` | ftp.proxy - FTP Proxy Server |
|  | [genshin-checkin-helper](https://gitlab.com/y1ndan/genshin-checkin-helper) | b9e36543bfe5b042e015463e5d0398cd234cba90 | `genshin-checkin-helper` | More than check-in for Genshin Impact. |
|  | [genshinhelper2](https://gitlab.com/y1ndan/genshinhelper2) | e786dedd153fb551baded7ee77d7eefa909555f7 | `genshinhelper2` | A Python library for miHoYo bbs and HoYoLAB Community. |
|  | [glauth](https://github.com/glauth/glauth) | v2.2.0-RC1 | `glauth` | A lightweight LDAP server for development, home use, or CI |
|  | [gopherus](http://gopherus.sourceforge.net/) | 1.2.1 | `gopherus` | Gopherus is a free, multiplatform, console-mode gopher client that provides a classic text interface to the gopherspace. |
|  | [hath](https://e-hentai.org/) | 1.6.1 | `hath` | Hentai@Home |
|  | [hesuvi-hrir](https://sourceforge.net/projects/hesuvi/) | 2.0.0.1 | `hesuvi-hrir` | Headphone Surround Virtualizations for Equalizer APO |
|  | [hoyo-glyphs](https://github.com/SpeedyOrc-C/Hoyo-Glyphs) | f87da0abeb152e9caf0d84b039f9a37d4af3bfa6 | `hoyo-glyphs` | Constructed scripts by Hoyoverse 米哈游的架空文字  |
|  | [kaixinsong-fonts](http://www.guoxuedashi.net/zidian/bujian/KaiXinSong.php) | 3.0 | `kaixinsong-fonts` | KaiXinSong |
|  | [konnect](https://github.com/Kopano-dev/konnect) | v0.34.0 | `konnect` | Kopano Konnect implements an OpenID provider (OP) with integrated web login and consent forms. |
|  | [ldap-auth-proxy](https://github.com/pinepain/ldap-auth-proxy) | 66a8236af574f554478fe376051b95f61235efc9 | `ldap-auth-proxy` | A simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend. |
|  | [libnftnl](https://netfilter.org/projects/libnftnl/) | 1.2.4 | `libnftnl-fullcone` | A userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem |
|  | [liboqs](https://openquantumsafe.org) | 0.7.2 | `liboqs` | C library for prototyping and experimenting with quantum-resistant cryptography |
|  | [netboot-xyz](https://netboot.xyz/) | 2.0.66 | `netboot-xyz` | Your favorite operating systems in one place. A network-based bootable operating system installer based on iPXE. |
|  | [netns-exec](https://github.com/pekman/netns-exec) | aa346fd058d47b238ae1b86250f414bcab2e7927 | `netns-exec` | Run command in Linux network namespace as normal user |
|  | [nftables](https://netfilter.org/projects/nftables/) | 1.0.6 | `nftables-fullcone` | The project that aims to replace the existing {ip,ip6,arp,eb}tables framework |
|  | [noise-suppression-for-voice](https://github.com/werman/noise-suppression-for-voice) | v1.03 | `noise-suppression-for-voice` | Noise suppression plugin based on Xiph's RNNoise |
|  | [nullfs](https://github.com/xrgtn/nullfs) | 0884f87ec01faaee219f59742c14ed3c3945f5c0 | `nullfs` | FUSE nullfs drivers |
|  | [nvlax](https://github.com/illnyang/nvlax) | b3699ad40c4dfbb9d46c53325d63ae8bf4a94d7f | `nvlax` | Future-proof NvENC & NvFBC patcher |
|  | [onepush](https://gitlab.com/y1ndan/onepush) | c7dd8c82e4eb74501d7e6bcf0c42d1caa0c0ffc2 | `onepush` | A Python library to send notifications to your iPhone, Discord, Telegram, WeChat, QQ and DingTalk. |
|  | [openssl-oqs](https://www.openssl.org/) | 1.1.1 | `openssl-oqs` | A cryptographic library that implements the SSL and TLS protocols |
|  | [openssl-oqs-provider](https://openquantumsafe.org) | deb4ec9e1b031a4b759aff5bb24827223b5b3bc6 | `openssl-oqs-provider` | OpenSSL 3 provider containing post-quantum algorithms |
|  | [osdlyrics](https://github.com/osdlyrics/osdlyrics) | 0.5.12 | `osdlyrics` | Standalone lyrics fetcher/displayer (windowed and OSD mode). |
|  | [payload-dumper-go](https://github.com/ssut/payload-dumper-go) | 1.2.2 | `payload-dumper-go` | An android OTA payload dumper written in Go |
|  | [phpmyadmin](https://www.phpmyadmin.net/) | 5.2.0 | `phpmyadmin` | A web interface for MySQL and MariaDB |
|  | [phppgadmin](https://github.com/phppgadmin/phppgadmin) | v7.14.3-mod | `phppgadmin` | The premier web-based administration tool for PostgreSQL |
|  | [qbittorrent-enhanced-edition](https://www.qbittorrent.org/) | release-4.5.0.10 | `qbittorrent-enhanced-edition` | Featureful free software BitTorrent client |
|  | [qbittorrent-enhanced-edition](https://www.qbittorrent.org/) | release-4.5.0.10 | `qbittorrent-enhanced-edition-nox` | Featureful free software BitTorrent client |
|  | [qemu-user-static](http://www.qemu.org/) | 7.2+dfsg-1 | `qemu-user-static` | A generic and open source machine emulator and virtualizer |
|  | [qq](https://im.qq.com/linuxqq/index.html) | 3.0.0-571 | `qq` | QQ for Linux |
|  | [qqmusic](https://y.qq.com/) | 1.1.5 | `qqmusic` | Tencent QQ Music (Untested) |
|  | [rime-aurora-pinyin](https://github.com/hosxy/rime-aurora-pinyin) | 122b46976401995cbafcfc748806985ff3a437a4 | `rime-aurora-pinyin` | 【极光拼音】输入方案 |
|  | [rime-dict](https://github.com/Iorest/rime-dict) | 325ecbda51cd93e07e2fe02e37e5f14d94a4a541 | `rime-dict` | RIME 词库增强 |
|  | [rime-moegirl](https://github.com/outloudvi/mw2fcitx/releases) | 20221214 | `rime-moegirl` | Releases for dict of zh.moegirl.org.cn |
|  | [rime-zhwiki](https://github.com/felixonmars/fcitx5-pinyin-zhwiki) | 20220416 | `rime-zhwiki` | Fcitx 5 Pinyin Dictionary from zh.wikipedia.org |
|  | [route-chain](https://github.com/xddxdd/route-chain) | e68c96e5e4df70c797d5a99acc8226713a22d7f5 | `route-chain` | A small app to generate a long path in traceroute. |
|  | [svp](https://www.svp-team.com/wiki/SVP:Linux) | 4.5.210 | `svp` | SmoothVideo Project 4 (SVP4) |
|  | [tachidesk-server](https://github.com/Suwayomi/Tachidesk-Server) | 0.6.2-r1074 | `tachidesk-server` | A rewrite of Tachiyomi for the Desktop |
| `Broken` | [vs-rife](https://github.com/HolyWu/vs-rife) | v3.1.0 | `vs-rife` | Real-Time Intermediate Flow Estimation for Video Frame Interpolation for VapourSynth |
|  | [wechat-uos](https://weixin.qq.com/) | 2.1.5 | `wechat-uos` | WeChat desktop (System Electron) |
|  | [wechat-uos-bin](https://weixin.qq.com/) | 2.1.5 | `wechat-uos-bin` | WeChat desktop (Official binary) |
|  | [wine-wechat](https://weixin.qq.com/) | 3.7.6 | `wine-wechat` | Wine WeChat |
</details>


<details>
<summary>Package set: asteriskDigiumCodecs (36 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | [asterisk-11-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.11.silk` | Asterisk 11 silk Codec by Digium |
|  | [asterisk-11-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.11.siren14` | Asterisk 11 siren14 Codec by Digium |
|  | [asterisk-11-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.11.siren7` | Asterisk 11 siren7 Codec by Digium |
|  | [asterisk-12-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.12.silk` | Asterisk 12 silk Codec by Digium |
|  | [asterisk-13-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.13.opus` | Asterisk 13 opus Codec by Digium |
|  | [asterisk-13-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.13.silk` | Asterisk 13 silk Codec by Digium |
|  | [asterisk-13-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.13.siren14` | Asterisk 13 siren14 Codec by Digium |
|  | [asterisk-13-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.13.siren7` | Asterisk 13 siren7 Codec by Digium |
|  | [asterisk-14-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.14.opus` | Asterisk 14 opus Codec by Digium |
|  | [asterisk-14-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.14.silk` | Asterisk 14 silk Codec by Digium |
|  | [asterisk-14-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.14.siren14` | Asterisk 14 siren14 Codec by Digium |
|  | [asterisk-14-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.14.siren7` | Asterisk 14 siren7 Codec by Digium |
|  | [asterisk-15-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.15.opus` | Asterisk 15 opus Codec by Digium |
|  | [asterisk-15-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.15.silk` | Asterisk 15 silk Codec by Digium |
|  | [asterisk-15-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.15.siren14` | Asterisk 15 siren14 Codec by Digium |
|  | [asterisk-15-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.15.siren7` | Asterisk 15 siren7 Codec by Digium |
|  | [asterisk-16-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.16.opus` | Asterisk 16 opus Codec by Digium |
|  | [asterisk-16-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.16.silk` | Asterisk 16 silk Codec by Digium |
|  | [asterisk-16-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.16.siren14` | Asterisk 16 siren14 Codec by Digium |
|  | [asterisk-16-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.16.siren7` | Asterisk 16 siren7 Codec by Digium |
|  | [asterisk-17-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.17.opus` | Asterisk 17 opus Codec by Digium |
|  | [asterisk-17-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.17.silk` | Asterisk 17 silk Codec by Digium |
|  | [asterisk-17-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.17.siren14` | Asterisk 17 siren14 Codec by Digium |
|  | [asterisk-17-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.17.siren7` | Asterisk 17 siren7 Codec by Digium |
|  | [asterisk-18-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.18.opus` | Asterisk 18 opus Codec by Digium |
|  | [asterisk-18-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.18.silk` | Asterisk 18 silk Codec by Digium |
|  | [asterisk-18-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.18.siren14` | Asterisk 18 siren14 Codec by Digium |
|  | [asterisk-18-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.18.siren7` | Asterisk 18 siren7 Codec by Digium |
|  | [asterisk-19-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.19.opus` | Asterisk 19 opus Codec by Digium |
|  | [asterisk-19-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.19.silk` | Asterisk 19 silk Codec by Digium |
|  | [asterisk-19-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.19.siren14` | Asterisk 19 siren14 Codec by Digium |
|  | [asterisk-19-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.19.siren7` | Asterisk 19 siren7 Codec by Digium |
|  | [asterisk-20-codec-opus](https://downloads.digium.com/pub/telephony/codec_opus/) | 1.3.0 | `asteriskDigiumCodecs.20.opus` | Asterisk 20 opus Codec by Digium |
|  | [asterisk-20-codec-silk](https://downloads.digium.com/pub/telephony/codec_silk/) | 1.0.3 | `asteriskDigiumCodecs.20.silk` | Asterisk 20 silk Codec by Digium |
|  | [asterisk-20-codec-siren14](https://downloads.digium.com/pub/telephony/codec_siren14/) | 1.0.7 | `asteriskDigiumCodecs.20.siren14` | Asterisk 20 siren14 Codec by Digium |
|  | [asterisk-20-codec-siren7](https://downloads.digium.com/pub/telephony/codec_siren7/) | 1.0.7 | `asteriskDigiumCodecs.20.siren7` | Asterisk 20 siren7 Codec by Digium |
</details>

<details>
<summary>Package set: lantianCustomized (12 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | [asterisk](https://www.asterisk.org/) | 20.0.0 | `lantianCustomized.asterisk` | Asterisk with Lan Tian modifications |
|  | [coredns-lantian](https://github.com/xddxdd/coredns) | 41a20197433c06398c7cfe17f1935c026b01c4fd | `lantianCustomized.coredns` | CoreDNS with Lan Tian's modifications |
|  | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | `lantianCustomized.linux-xanmod-lantian` | Linux Xanmod Kernel with Lan Tian Modifications |
|  | linux-config | 6.0.12-xanmod1 | `lantianCustomized.linux-xanmod-lantian-config` |  |
|  | [linux](https://www.kernel.org/) | 6.0.12-xanmod1 | `lantianCustomized.linux-xanmod-lantian-lto` | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | linux-config | 6.0.12-xanmod1 | `lantianCustomized.linux-xanmod-lantian-lto-config` |  |
|  | [linux](https://www.kernel.org/) | 6.1.3-xanmod1 | `lantianCustomized.linux-xanmod-lantian-unstable` | Linux Xanmod Kernel with Lan Tian Modifications |
|  | linux-config | 6.1.3-xanmod1 | `lantianCustomized.linux-xanmod-lantian-unstable-config` |  |
|  | [linux](https://www.kernel.org/) | 6.1.3-xanmod1 | `lantianCustomized.linux-xanmod-lantian-unstable-lto` | Linux Xanmod Kernel with Lan Tian Modifications and Clang+ThinLTO |
|  | linux-config | 6.1.3-xanmod1 | `lantianCustomized.linux-xanmod-lantian-unstable-lto-config` |  |
|  | [nbfc-linux-lantian](https://github.com/xddxdd/nbfc-linux) | 32a49117ca3ff17d7681713a8dc8812323142dcb | `lantianCustomized.nbfc-linux` | NoteBook FanControl ported to Linux (with Lan Tian's modifications) |
|  | [nginx-lantian](https://openresty.org) | 1.21.4.1 | `lantianCustomized.nginx` | OpenResty with Lan Tian modifications |
</details>

<details>
<summary>Package set: lantianPersonal (1 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | libltnginx | 96698a667740ac45ca4571a04a6cfe39caf926c0 | `lantianPersonal.libltnginx` |  |
</details>

<details>
<summary>Package set: openj9-ibm-semeru (62 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.17.0 | `openj9-ibm-semeru.jdk-bin-11` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.12.0 | `openj9-ibm-semeru.jdk-bin-11_0_12_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.13.0 | `openj9-ibm-semeru.jdk-bin-11_0_13_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.0 | `openj9-ibm-semeru.jdk-bin-11_0_14_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.1 | `openj9-ibm-semeru.jdk-bin-11_0_14_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.15.0 | `openj9-ibm-semeru.jdk-bin-11_0_15_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.0 | `openj9-ibm-semeru.jdk-bin-11_0_16_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.1 | `openj9-ibm-semeru.jdk-bin-11_0_16_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.17.0 | `openj9-ibm-semeru.jdk-bin-11_0_17_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | `openj9-ibm-semeru.jdk-bin-16` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | `openj9-ibm-semeru.jdk-bin-16_0_2_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.5.0 | `openj9-ibm-semeru.jdk-bin-17` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.1.0 | `openj9-ibm-semeru.jdk-bin-17_0_1_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.2.0 | `openj9-ibm-semeru.jdk-bin-17_0_2_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.3.0 | `openj9-ibm-semeru.jdk-bin-17_0_3_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.0 | `openj9-ibm-semeru.jdk-bin-17_0_4_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.1 | `openj9-ibm-semeru.jdk-bin-17_0_4_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.5.0 | `openj9-ibm-semeru.jdk-bin-17_0_5_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | `openj9-ibm-semeru.jdk-bin-18` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.0 | `openj9-ibm-semeru.jdk-bin-18_0_1_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.1 | `openj9-ibm-semeru.jdk-bin-18_0_1_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.0 | `openj9-ibm-semeru.jdk-bin-18_0_2_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | `openj9-ibm-semeru.jdk-bin-18_0_2_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.352.0 | `openj9-ibm-semeru.jdk-bin-8` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.302.0 | `openj9-ibm-semeru.jdk-bin-8_0_302_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.312.0 | `openj9-ibm-semeru.jdk-bin-8_0_312_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.322.0 | `openj9-ibm-semeru.jdk-bin-8_0_322_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.332.0 | `openj9-ibm-semeru.jdk-bin-8_0_332_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.0 | `openj9-ibm-semeru.jdk-bin-8_0_345_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.1 | `openj9-ibm-semeru.jdk-bin-8_0_345_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jdk-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.352.0 | `openj9-ibm-semeru.jdk-bin-8_0_352_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.17.0 | `openj9-ibm-semeru.jre-bin-11` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.12.0 | `openj9-ibm-semeru.jre-bin-11_0_12_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.13.0 | `openj9-ibm-semeru.jre-bin-11_0_13_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.0 | `openj9-ibm-semeru.jre-bin-11_0_14_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.14.1 | `openj9-ibm-semeru.jre-bin-11_0_14_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.15.0 | `openj9-ibm-semeru.jre-bin-11_0_15_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.0 | `openj9-ibm-semeru.jre-bin-11_0_16_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.16.1 | `openj9-ibm-semeru.jre-bin-11_0_16_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 11.0.17.0 | `openj9-ibm-semeru.jre-bin-11_0_17_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | `openj9-ibm-semeru.jre-bin-16` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 16.0.2.0 | `openj9-ibm-semeru.jre-bin-16_0_2_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.5.0 | `openj9-ibm-semeru.jre-bin-17` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.1.0 | `openj9-ibm-semeru.jre-bin-17_0_1_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.2.0 | `openj9-ibm-semeru.jre-bin-17_0_2_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.3.0 | `openj9-ibm-semeru.jre-bin-17_0_3_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.0 | `openj9-ibm-semeru.jre-bin-17_0_4_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.4.1 | `openj9-ibm-semeru.jre-bin-17_0_4_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 17.0.5.0 | `openj9-ibm-semeru.jre-bin-17_0_5_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | `openj9-ibm-semeru.jre-bin-18` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.0 | `openj9-ibm-semeru.jre-bin-18_0_1_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.1.1 | `openj9-ibm-semeru.jre-bin-18_0_1_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.0 | `openj9-ibm-semeru.jre-bin-18_0_2_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 18.0.2.1 | `openj9-ibm-semeru.jre-bin-18_0_2_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.352.0 | `openj9-ibm-semeru.jre-bin-8` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.302.0 | `openj9-ibm-semeru.jre-bin-8_0_302_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.312.0 | `openj9-ibm-semeru.jre-bin-8_0_312_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.322.0 | `openj9-ibm-semeru.jre-bin-8_0_322_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.332.0 | `openj9-ibm-semeru.jre-bin-8_0_332_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.0 | `openj9-ibm-semeru.jre-bin-8_0_345_0` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.345.1 | `openj9-ibm-semeru.jre-bin-8_0_345_1` | OpenJ9 binaries built by IBM Semeru |
|  | [openj9-ibm-semeru-jre-bin](https://developer.ibm.com/languages/java/semeru-runtimes/) | 8.0.352.0 | `openj9-ibm-semeru.jre-bin-8_0_352_0` | OpenJ9 binaries built by IBM Semeru |
</details>

<details>
<summary>Package set: openjdk-adoptium (60 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.17_8_adopt | `openjdk-adoptium.jdk-bin-11` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.12_7_adopt | `openjdk-adoptium.jdk-bin-11_0_12_7` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.13_8_adopt | `openjdk-adoptium.jdk-bin-11_0_13_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.14.1_1_adopt | `openjdk-adoptium.jdk-bin-11_0_14_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.14_9_adopt | `openjdk-adoptium.jdk-bin-11_0_14_9` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.15_10_adopt | `openjdk-adoptium.jdk-bin-11_0_15_10` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.16.1_1_adopt | `openjdk-adoptium.jdk-bin-11_0_16_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.16_8_adopt | `openjdk-adoptium.jdk-bin-11_0_16_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 11.0.17_8_adopt | `openjdk-adoptium.jdk-bin-11_0_17_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 16.0.2_7_adopt | `openjdk-adoptium.jdk-bin-16` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 16.0.2_7_adopt | `openjdk-adoptium.jdk-bin-16_0_2_7` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.5_8_adopt | `openjdk-adoptium.jdk-bin-17` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.1_12_adopt | `openjdk-adoptium.jdk-bin-17_0_1_12` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.2_8_adopt | `openjdk-adoptium.jdk-bin-17_0_2_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.3_7_adopt | `openjdk-adoptium.jdk-bin-17_0_3_7` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.4.1_1_adopt | `openjdk-adoptium.jdk-bin-17_0_4_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.4_8_adopt | `openjdk-adoptium.jdk-bin-17_0_4_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17.0.5_8_adopt | `openjdk-adoptium.jdk-bin-17_0_5_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 17_35_adopt | `openjdk-adoptium.jdk-bin-17_35` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | `openjdk-adoptium.jdk-bin-18` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.1_10_adopt | `openjdk-adoptium.jdk-bin-18_0_1_10` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | `openjdk-adoptium.jdk-bin-18_0_2_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18.0.2_9_adopt | `openjdk-adoptium.jdk-bin-18_0_2_9` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 18_36_adopt | `openjdk-adoptium.jdk-bin-18_36` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u352-b08_adopt | `openjdk-adoptium.jdk-bin-8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u302-b08 | `openjdk-adoptium.jdk-bin-8u302_b08` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u312-b07 | `openjdk-adoptium.jdk-bin-8u312_b07` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u322-b06_adopt | `openjdk-adoptium.jdk-bin-8u322_b06` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u332-b09_adopt | `openjdk-adoptium.jdk-bin-8u332_b09` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u342-b07_adopt | `openjdk-adoptium.jdk-bin-8u342_b07` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u345-b01_adopt | `openjdk-adoptium.jdk-bin-8u345_b01` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jdk-bin](https://adoptium.net/) | 8u352-b08_adopt | `openjdk-adoptium.jdk-bin-8u352_b08` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.17_8_adopt | `openjdk-adoptium.jre-bin-11` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.12_7_adopt | `openjdk-adoptium.jre-bin-11_0_12_7` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.13_8_adopt | `openjdk-adoptium.jre-bin-11_0_13_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.14.1_1_adopt | `openjdk-adoptium.jre-bin-11_0_14_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.14_9_adopt | `openjdk-adoptium.jre-bin-11_0_14_9` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.15_10_adopt | `openjdk-adoptium.jre-bin-11_0_15_10` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.16.1_1_adopt | `openjdk-adoptium.jre-bin-11_0_16_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.16_8_adopt | `openjdk-adoptium.jre-bin-11_0_16_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 11.0.17_8_adopt | `openjdk-adoptium.jre-bin-11_0_17_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.5_8_adopt | `openjdk-adoptium.jre-bin-17` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.1_12_adopt | `openjdk-adoptium.jre-bin-17_0_1_12` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.2_8_adopt | `openjdk-adoptium.jre-bin-17_0_2_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.3_7_adopt | `openjdk-adoptium.jre-bin-17_0_3_7` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.4.1_1_adopt | `openjdk-adoptium.jre-bin-17_0_4_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.4_8_adopt | `openjdk-adoptium.jre-bin-17_0_4_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 17.0.5_8_adopt | `openjdk-adoptium.jre-bin-17_0_5_8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | `openjdk-adoptium.jre-bin-18` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.1_10_adopt | `openjdk-adoptium.jre-bin-18_0_1_10` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.2.1_1_adopt | `openjdk-adoptium.jre-bin-18_0_2_1_1` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 18.0.2_9_adopt | `openjdk-adoptium.jre-bin-18_0_2_9` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u352-b08_adopt | `openjdk-adoptium.jre-bin-8` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u302-b08 | `openjdk-adoptium.jre-bin-8u302_b08` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u312-b07 | `openjdk-adoptium.jre-bin-8u312_b07` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u322-b06_adopt | `openjdk-adoptium.jre-bin-8u322_b06` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u332-b09_adopt | `openjdk-adoptium.jre-bin-8u332_b09` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u342-b07_adopt | `openjdk-adoptium.jre-bin-8u342_b07` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u345-b01_adopt | `openjdk-adoptium.jre-bin-8u345_b01` | OpenJDK binaries built by Eclipse Adoptium |
|  | [openjdk-adoptium-jre-bin](https://adoptium.net/) | 8u352-b08_adopt | `openjdk-adoptium.jre-bin-8u352_b08` | OpenJDK binaries built by Eclipse Adoptium |
</details>

<details>
<summary>Package set: plangothic-fonts (2 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | [plangothic-fonts-allideo](https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic) | V0.7.5708 | `plangothic-fonts.allideo` | Plangothic Project |
|  | [plangothic-fonts-fallback](https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic) | V0.7.5708 | `plangothic-fonts.fallback` | Plangothic Project |
</details>

<details>
<summary>Package set: th-fonts (10 packages)</summary>

| State | Name | Version | Path | Description |
| ----- | ---- | ------- | ---- | ----------- |
|  | [TH-Feon](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.feon` | TH-Feon font |
|  | [TH-Hak](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.hak` | TH-Hak font |
|  | [TH-Joeng](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.joeng` | TH-Joeng font |
|  | [TH-Khaai-P](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.khaai-p` | TH-Khaai-P font |
|  | [TH-Khaai-T](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.khaai-t` | TH-Khaai-T font |
|  | [TH-Ming](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.ming` | TH-Ming font |
|  | [TH-Sung-P](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.sung-p` | TH-Sung-P font |
|  | [TH-Sung-T](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.sung-t` | TH-Sung-T font |
|  | [TH-Sy](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.sy` | TH-Sy font |
|  | [TH-Tshyn](http://cheonhyeong.com/Simplified/download.html) | 3.0.0 | `th-fonts.tshyn` | TH-Tshyn font |
</details>

