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
    linux-xanmod-lantian = ifNotCI (pkg ./lantian-customized/linux-xanmod-lantian { });
    linux-xanmod-lantian-config = ifNotCI lantianCustomized.linux-xanmod-lantian.configfile;
    nbfc-linux = pkg ./lantian-customized/nbfc-linux { };
    openresty = pkg ./lantian-customized/openresty { };
  };
  lantianPersonal = pkgs.recurseIntoAttrs {
    # Personal packages with no intention to be used by others
    dngzwxdq = pkg ./lantian-personal/dngzwxdq { inherit chmlib-utils; };
    dnyjzsxj = pkg ./lantian-personal/dnyjzsxj { inherit chmlib-utils; };
    glibc-debian-openvz-files = pkg ./lantian-personal/glibc-debian-openvz-files { };
  };
  openj9-ibm-semeru = ifNotCI (pkgs.recurseIntoAttrs (pkg ./openj9-ibm-semeru { }));
  openjdk-adoptium = ifNotCI (pkgs.recurseIntoAttrs (pkg ./openjdk-adoptium { }));
  th-fonts = pkgs.recurseIntoAttrs (pkg ./th-fonts { });

  # Other packages
  asterisk-g72x = pkg ./asterisk-g72x { };
  baidupcs-go = pkg ./baidupcs-go { };
  bilibili = pkg ./bilibili { };
  bird-babel-rtt = pkg ./bird-babel-rtt { };
  bird-lg-go = pkg ./bird-lg-go { };
  bird-lgproxy-go = pkg ./bird-lgproxy-go { };
  boringssl-oqs = pkg ./boringssl-oqs {
    inherit liboqs;
  };
  calibre-cops = pkg ./calibre-cops { };
  chmlib-utils = pkg ./chmlib-utils { };
  cloudpan189-go = pkg ./cloudpan189-go { };
  deepspeech-gpu = pkg ./deepspeech-gpu { };
  deepspeech-wrappers = pkg ./deepspeech-gpu/wrappers.nix { };
  dingtalk = pkg ./dingtalk { };
  dn42-pingfinder = pkg ./dn42-pingfinder { };
  drone-vault = pkg ./drone-vault { };
  etherguard = pkg ./etherguard { };
  fcitx5-breeze = pkg ./fcitx5-breeze { };
  ftp-proxy = pkg ./ftp-proxy { };
  genshin-checkin-helper = pkg ./genshin-checkin-helper {
    inherit genshinhelper2 onepush;
  };
  genshinhelper2 = pkg ./genshinhelper2 { };
  glauth = pkg ./glauth { };
  gopherus = pkg ./gopherus { };
  grasscutter = pkg ./grasscutter { };
  hath = pkg ./hath { };
  hesuvi-hrir = pkg ./hesuvi-hrir { };
  hoyo-glyphs = pkg ./hoyo-glyphs { };
  kaixinsong-fonts = pkg ./kaixinsong-fonts { };
  konnect = pkg ./konnect { };
  ldap-auth-proxy = pkg ./ldap-auth-proxy { };
  libltnginx = pkg ./libltnginx { };
  liboqs = pkg ./liboqs { };
  netboot-xyz = pkg ./netboot-xyz { };
  netns-exec = pkg ./netns-exec { };
  noise-suppression-for-voice = pkg ./noise-suppression-for-voice { };
  nullfs = pkg ./nullfs { };
  onepush = pkg ./onepush { };
  openssl-oqs = pkg ./openssl-oqs {
    inherit liboqs;
    cryptodev = pkgs.linuxPackages.cryptodev;
  };
  openssl-oqs-provider = pkg ./openssl-oqs-provider {
    inherit liboqs;
  };
  osdlyrics = pkg ./osdlyrics { };
  phpmyadmin = pkg ./phpmyadmin { };
  phppgadmin = pkg ./phppgadmin { };
  qbittorrent-enhanced-edition = pkg ./qbittorrent-enhanced-edition { };
  qemu-user-static = pkg ./qemu-user-static { };
  qq = pkg ./qq { };
  qqmusic = pkg ./qqmusic { };
  rime-aurora-pinyin = pkg ./rime-aurora-pinyin { };
  rime-dict = pkg ./rime-dict { };
  rime-moegirl = pkg ./rime-moegirl { };
  rime-zhwiki = pkg ./rime-zhwiki { };
  route-chain = pkg ./route-chain { };
  svp = pkg ./svp { };
  tachidesk-server = pkg ./tachidesk-server { };
  vs-rife = pkg ./vs-rife { };
  wechat-uos = pkg ./wechat-uos { };
  wechat-uos-bin = pkg ./wechat-uos/official-bin.nix { };
  wine-wechat = pkg ./wine-wechat { };
  xray = pkg ./xray { };
}
