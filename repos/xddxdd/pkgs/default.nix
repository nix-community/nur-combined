# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs ? import <nixpkgs> {},
  inputs ? null,
  ci ? false,
  nvidia_x11 ? pkgs.linuxPackages_latest.nvidia_x11,
  ...
}: let
  inherit (pkgs) lib;

  ifNotCI = p:
    if ci
    then null
    else p;
  ifFlakes = p:
    if inputs != null
    then p
    else null;

  mkScope = f:
    builtins.removeAttrs
    (lib.makeScope pkgs.newScope (self: let
      pkg = self.newScope {
        inherit mkScope nvidia_x11;
        sources = self.callPackage ../_sources/generated.nix {};
      };
    in
      f self pkg))
    [
      "newScope"
      "callPackage"
      "overrideScope"
      "overrideScope'"
      "packages"
    ];
in
  mkScope (self: pkg: rec {
    # Binary cache information
    _meta = pkgs.recurseIntoAttrs {
      url = "https://xddxdd.cachix.org";
      publicKey = "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=";

      howto = pkg ./_meta/howto {};
      readme = pkg ./_meta/readme {};
    };

    # Package groups
    asteriskDigiumCodecs = pkgs.recurseIntoAttrs (pkg ./asterisk-digium-codecs {});

    lantianCustomized = ifNotCI (pkgs.recurseIntoAttrs {
      # Packages with significant customization by Lan Tian
      asterisk = pkg ./lantian-customized/asterisk {};
      coredns = pkg ./lantian-customized/coredns {};

      linux-xanmod-lantian = self.lantianLinuxXanmod.generic;
      linux-xanmod-lantian-lto = self.lantianLinuxXanmod.generic-lto;

      # Temporary package to test a problem with Btrfs Linux 6.1
      # Replaced since Btrfs is fixed in latest Linux 6.1
      linux-xanmod-lantian-unstable = self.lantianLinuxXanmod.generic;
      linux-xanmod-lantian-unstable-lto = self.lantianLinuxXanmod.generic-lto;

      nbfc-linux = pkg ./lantian-customized/nbfc-linux {};
      nginx = pkg ./lantian-customized/nginx {};
      transmission-with-webui = pkg ./lantian-customized/transmission-with-webui {};
    });

    lantianLinuxXanmod = ifNotCI (pkgs.recurseIntoAttrs (pkg ./lantian-linux-xanmod {}));

    lantianPersonal = ifNotCI (pkgs.recurseIntoAttrs {
      # Personal packages with no intention to be used by others
      libltnginx = pkg ./lantian-personal/libltnginx {};
    });

    openj9-ibm-semeru = ifNotCI (pkgs.recurseIntoAttrs (pkg ./openj9-ibm-semeru {}));
    openjdk-adoptium = ifNotCI (pkgs.recurseIntoAttrs (pkg ./openjdk-adoptium {}));
    plangothic-fonts = pkgs.recurseIntoAttrs (pkg ./plangothic-fonts {});
    th-fonts = pkgs.recurseIntoAttrs (pkg ./th-fonts {});

    # Other packages
    asterisk-g72x = pkg ./uncategorized/asterisk-g72x {};
    baidupcs-go = pkg ./uncategorized/baidupcs-go {};
    bepasty = pkg ./uncategorized/bepasty {};
    bilibili = pkg ./uncategorized/bilibili {};
    bird-babel-rtt = pkg ./uncategorized/bird-babel-rtt {};
    bird-lg-go = pkg ./uncategorized/bird-lg-go {};
    bird-lgproxy-go = pkg ./uncategorized/bird-lgproxy-go {};
    boringssl-oqs = pkg ./uncategorized/boringssl-oqs {};
    calibre-cops = pkg ./uncategorized/calibre-cops {};
    chmlib-utils = pkg ./uncategorized/chmlib-utils {};
    chromium-oqs-bin = pkg ./uncategorized/chromium-oqs-bin {};
    cloudpan189-go = pkg ./uncategorized/cloudpan189-go {};
    deepspeech-gpu = ifNotCI (pkg ./uncategorized/deepspeech-gpu {});
    deepspeech-wrappers = ifNotCI (pkg ./uncategorized/deepspeech-gpu/wrappers.nix {});
    dingtalk = pkg ./uncategorized/dingtalk {};
    dn42-pingfinder = pkg ./uncategorized/dn42-pingfinder {};
    douban-openapi-server = pkg ./uncategorized/douban-openapi-server {};
    drone-vault = pkg ./uncategorized/drone-vault {};
    etherguard = pkg ./uncategorized/etherguard {};
    fcitx5-breeze = pkg ./uncategorized/fcitx5-breeze {};
    flaresolverr = pkg ./uncategorized/flaresolverr {};
    flasgger = pkg ./uncategorized/flasgger {};
    ftp-proxy = pkg ./uncategorized/ftp-proxy {};
    genshin-checkin-helper = pkg ./uncategorized/genshin-checkin-helper {};
    genshinhelper2 = pkg ./uncategorized/genshinhelper2 {};
    glauth = ifNotCI (pkg ./uncategorized/glauth {});
    google-earth-pro = pkg ./uncategorized/google-earth-pro {};
    gopherus = pkg ./uncategorized/gopherus {};
    grasscutter = pkg ./uncategorized/grasscutter {};
    hath = pkg ./uncategorized/hath {};

    # This package is failing on CI for unknown reason
    hesuvi-hrir = ifNotCI (pkg ./uncategorized/hesuvi-hrir {});

    hoyo-glyphs = pkg ./uncategorized/hoyo-glyphs {};
    kaixinsong-fonts = pkg ./uncategorized/kaixinsong-fonts {};
    kata-image = pkg ./uncategorized/kata-image {};
    kata-runtime = pkg ./uncategorized/kata-runtime {};
    konnect = pkg ./uncategorized/konnect {};
    ldap-auth-proxy = pkg ./uncategorized/ldap-auth-proxy {};
    libnftnl-fullcone = pkg ./uncategorized/libnftnl-fullcone {};
    liboqs = pkg ./uncategorized/liboqs {};
    netboot-xyz = pkg ./uncategorized/netboot-xyz {};
    netns-exec = pkg ./uncategorized/netns-exec {};
    nftables-fullcone = pkg ./uncategorized/nftables-fullcone {};
    noise-suppression-for-voice = pkg ./uncategorized/noise-suppression-for-voice {};
    nullfs = pkg ./uncategorized/nullfs {};
    nvlax = pkg ./uncategorized/nvlax {};
    onepush = pkg ./uncategorized/onepush {};
    openssl-oqs = pkg ./uncategorized/openssl-oqs {cryptodev = pkgs.linuxPackages.cryptodev;};
    openssl-oqs-provider = pkg ./uncategorized/openssl-oqs-provider {};
    osdlyrics = pkg ./uncategorized/osdlyrics {};
    payload-dumper-go = pkg ./uncategorized/payload-dumper-go {};
    phpmyadmin = pkg ./uncategorized/phpmyadmin {};
    phppgadmin = pkg ./uncategorized/phppgadmin {};
    qbittorrent-enhanced-edition = pkg ./uncategorized/qbittorrent-enhanced-edition {};
    qbittorrent-enhanced-edition-nox = pkg ./uncategorized/qbittorrent-enhanced-edition/nox.nix {};
    qemu-user-static = pkg ./uncategorized/qemu-user-static {};
    qq = pkg ./uncategorized/qq {};
    qqmusic = pkg ./uncategorized/qqmusic {};
    rime-aurora-pinyin = pkg ./uncategorized/rime-aurora-pinyin {};
    rime-dict = pkg ./uncategorized/rime-dict {};
    rime-moegirl = pkg ./uncategorized/rime-moegirl {};
    rime-zhwiki = pkg ./uncategorized/rime-zhwiki {};
    route-chain = pkg ./uncategorized/route-chain {};
    sgx-software-enable = pkg ./uncategorized/sgx-software-enable {};
    space-cadet-pinball-full-tilt = pkg ./uncategorized/space-cadet-pinball-full-tilt {};
    svp = pkg ./uncategorized/svp {};
    tachidesk-server = pkg ./uncategorized/tachidesk-server {};
    undetected-chromedriver = pkg ./uncategorized/undetected-chromedriver {};
    undetected-chromedriver-bin = pkg ./uncategorized/undetected-chromedriver-bin {};
    vs-rife = pkg ./uncategorized/vs-rife {};
    wechat-uos = pkg ./uncategorized/wechat-uos {};
    wechat-uos-bin = pkg ./uncategorized/wechat-uos/official-bin.nix {};

    # In case of wechat update, use:
    # (wine-wechat.override {
    #   version = "1.2.3";
    #   setupSrc = fetchurl {
    #     url = "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe";
    #     sha256 = "xxx";
    #   };
    # })
    wine-wechat = lib.makeOverridable pkg ./uncategorized/wine-wechat {};

    xstatic-asciinema-player = pkg ./uncategorized/xstatic-asciinema-player {};
    xstatic-font-awesome = pkg ./uncategorized/xstatic-font-awesome {};
  })
