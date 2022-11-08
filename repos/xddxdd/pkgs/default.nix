# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { }
, inputs ? null
, ci ? false
, ...
}:

let
  sources = pkgs.callPackage ../_sources/generated.nix { };
  pkg = path: args: pkgs.callPackage path ({
    inherit sources;
  } // args);
  ifNotCI = p: if ci then null else p;
  ifFlakes = p: if inputs != null then p else null;
in
rec {
  # Binary cache information
  _binaryCache = pkgs.recurseIntoAttrs rec {
    url = "https://xddxdd.cachix.org";
    publicKey = "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=";

    readme = pkgs.writeTextFile rec {
      name = "00000-readme";
      text = ''
        This NUR has a binary cache. Use the following settings to access it:

        nix.settings.substituters = [ "${url}" ];
        nix.settings.trusted-public-keys = [ "${publicKey}" ];

        Or, use variables from this repository in case I change them:

        nix.settings.substituters = [ nur.repos.xddxdd._binaryCache.url ];
        nix.settings.trusted-public-keys = [ nur.repos.xddxdd._binaryCache.publicKey ];

        Or, if you use NixOS <= 21.11:

        nix.binaryCaches = [ "${url}" ];
        nix.binaryCachePublicKeys = [ "${publicKey}" ];
      '';
      meta = {
        description = text;
        homepage = "https://github.com/xddxdd/nur-packages";
        license = pkgs.lib.licenses.unlicense;
      };
    };
  };

  # Package groups
  asteriskDigiumCodecs = pkgs.recurseIntoAttrs (pkg ./asterisk-digium-codecs { });
  lantianCustomized = pkgs.recurseIntoAttrs {
    # Packages with significant customization by Lan Tian
    asterisk = pkg ./lantian-customized/asterisk {
      inherit asteriskDigiumCodecs asterisk-g72x;
    };
    coredns = pkg ./lantian-customized/coredns { };
    keycloak-lantian = ifFlakes (pkg ./lantian-customized/keycloak-lantian {
      inherit (inputs) keycloak-lantian;
    });
    linux-xanmod-lantian = ifNotCI (pkg ./lantian-customized/linux-xanmod-lantian { lto = false; });
    linux-xanmod-lantian-config = ifNotCI lantianCustomized.linux-xanmod-lantian.configfile;
    linux-xanmod-lantian-lto = ifNotCI (pkg ./lantian-customized/linux-xanmod-lantian { lto = true; });
    linux-xanmod-lantian-lto-config = ifNotCI lantianCustomized.linux-xanmod-lantian-lto.configfile;
    nbfc-linux = pkg ./lantian-customized/nbfc-linux { };
    openresty = pkg ./lantian-customized/openresty { };
  };
  lantianPersonal = pkgs.recurseIntoAttrs {
    # Personal packages with no intention to be used by others
    libltnginx = pkg ./lantian-personal/libltnginx { };
  };
  openj9-ibm-semeru = ifNotCI (pkgs.recurseIntoAttrs (pkg ./openj9-ibm-semeru { }));
  openjdk-adoptium = ifNotCI (pkgs.recurseIntoAttrs (pkg ./openjdk-adoptium { }));
  plangothic-fonts = pkg ./plangothic-fonts { };
  th-fonts = pkgs.recurseIntoAttrs (pkg ./th-fonts { });

  # Other packages
  asterisk-g72x = pkg ./uncategorized/asterisk-g72x { };
  baidupcs-go = pkg ./uncategorized/baidupcs-go { };
  bilibili = pkg ./uncategorized/bilibili { };
  bird-babel-rtt = pkg ./uncategorized/bird-babel-rtt { };
  bird-lg-go = pkg ./uncategorized/bird-lg-go { };
  bird-lgproxy-go = pkg ./uncategorized/bird-lgproxy-go { };
  boringssl-oqs = pkg ./uncategorized/boringssl-oqs {
    inherit liboqs;
  };
  calibre-cops = pkg ./uncategorized/calibre-cops { };
  chmlib-utils = pkg ./uncategorized/chmlib-utils { };
  chromium-oqs-bin = pkg ./uncategorized/chromium-oqs-bin { };
  cloudpan189-go = pkg ./uncategorized/cloudpan189-go { };
  deepspeech-gpu = pkg ./uncategorized/deepspeech-gpu {
    inherit (pkgs.linuxPackages_latest) nvidia_x11;
  };
  deepspeech-wrappers = pkg ./uncategorized/deepspeech-gpu/wrappers.nix {
    inherit (pkgs.linuxPackages_latest) nvidia_x11;
  };
  dingtalk = pkg ./uncategorized/dingtalk { };
  dn42-pingfinder = pkg ./uncategorized/dn42-pingfinder { };
  douban-openapi-server = pkg ./uncategorized/douban-openapi-server {
    inherit flasgger;
  };
  drone-vault = pkg ./uncategorized/drone-vault { };
  etherguard = pkg ./uncategorized/etherguard { };
  fcitx5-breeze = pkg ./uncategorized/fcitx5-breeze { };
  flasgger = pkg ./uncategorized/flasgger { };
  ftp-proxy = pkg ./uncategorized/ftp-proxy { };
  genshin-checkin-helper = pkg ./uncategorized/genshin-checkin-helper {
    inherit genshinhelper2 onepush;
  };
  genshinhelper2 = pkg ./uncategorized/genshinhelper2 { };
  glauth = pkg ./uncategorized/glauth { };
  gopherus = pkg ./uncategorized/gopherus { };
  hath = pkg ./uncategorized/hath { };
  hesuvi-hrir = pkg ./uncategorized/hesuvi-hrir { };
  hoyo-glyphs = pkg ./uncategorized/hoyo-glyphs { };
  kaixinsong-fonts = pkg ./uncategorized/kaixinsong-fonts { };
  konnect = pkg ./uncategorized/konnect { };
  ldap-auth-proxy = pkg ./uncategorized/ldap-auth-proxy { };
  liboqs = pkg ./uncategorized/liboqs { };
  netboot-xyz = pkg ./uncategorized/netboot-xyz { };
  netns-exec = pkg ./uncategorized/netns-exec { };
  noise-suppression-for-voice = pkg ./uncategorized/noise-suppression-for-voice { };
  nullfs = pkg ./uncategorized/nullfs { };
  nvlax = pkg ./uncategorized/nvlax { };
  onepush = pkg ./uncategorized/onepush { };
  openssl-oqs = pkg ./uncategorized/openssl-oqs {
    inherit liboqs;
    cryptodev = pkgs.linuxPackages.cryptodev;
  };
  openssl-oqs-provider = pkg ./uncategorized/openssl-oqs-provider {
    inherit liboqs;
  };
  osdlyrics = pkg ./uncategorized/osdlyrics { };
  payload-dumper-go = pkg ./uncategorized/payload-dumper-go { };
  phpmyadmin = pkg ./uncategorized/phpmyadmin { };
  phppgadmin = pkg ./uncategorized/phppgadmin { };
  qbittorrent-enhanced-edition = pkg ./uncategorized/qbittorrent-enhanced-edition { };
  qemu-user-static = pkg ./uncategorized/qemu-user-static { };
  qq = pkg ./uncategorized/qq { };
  qqmusic = pkg ./uncategorized/qqmusic { };
  rime-aurora-pinyin = pkg ./uncategorized/rime-aurora-pinyin { };
  rime-dict = pkg ./uncategorized/rime-dict { };
  rime-moegirl = pkg ./uncategorized/rime-moegirl { };
  rime-zhwiki = pkg ./uncategorized/rime-zhwiki { };
  route-chain = pkg ./uncategorized/route-chain { };
  svp = pkg ./uncategorized/svp {
    inherit (pkgs.linuxPackages_latest) nvidia_x11;
  };
  tachidesk-server = pkg ./uncategorized/tachidesk-server { };
  vs-rife = pkg ./uncategorized/vs-rife { };
  wechat-uos = pkg ./uncategorized/wechat-uos { };
  wechat-uos-bin = pkg ./uncategorized/wechat-uos/official-bin.nix { };

  # In case of wechat update, use (wine-wechat.override { version = "1.2.3"; sha256 = "xxx";})
  wine-wechat = pkgs.lib.makeOverridable pkg ./uncategorized/wine-wechat { };

  xray = pkg ./uncategorized/xray { };
}
