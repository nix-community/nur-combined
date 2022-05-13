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
in
rec {
  bird-lg-go = pkg ./bird-lg-go { };
  bird-lgproxy-go = pkg ./bird-lgproxy-go { };
  boringssl-oqs = pkg ./boringssl-oqs {
    inherit liboqs;
  };
  calibre-cops = pkg ./calibre-cops { };
  chmlib-utils = pkg ./chmlib-utils { };
  coredns-lantian = pkg ./coredns-lantian { };
  deepspeech-gpu = pkg ./deepspeech-gpu { };
  deepspeech-wrappers = pkg ./deepspeech-gpu/wrappers.nix { };
  dingtalk = pkg ./dingtalk { };
  dngzwxdq = pkg ./dngzwxdq {
    inherit chmlib-utils;
  };
  dnyjzsxj = pkg ./dnyjzsxj {
    inherit chmlib-utils;
  };
  drone-vault = pkg ./drone-vault { };
  fcitx5-breeze = pkg ./fcitx5-breeze { };
  ftp-proxy = pkg ./ftp-proxy { };
  genshin-checkin-helper = pkg ./genshin-checkin-helper {
    inherit genshinhelper2 onepush;
  };
  genshinhelper2 = pkg ./genshinhelper2 { };
  glauth = pkg ./glauth { };
  glibc-debian-openvz-files = pkg ./glibc-debian-openvz-files { };
  gopherus = pkg ./gopherus { };
  grasscutter = pkg ./grasscutter { };
  hath = pkg ./hath { };
  hesuvi-hrir = pkg ./hesuvi-hrir { };
  hoyo-glyphs = pkg ./hoyo-glyphs { };
  konnect = pkg ./konnect { };
  ldap-auth-proxy = pkg ./ldap-auth-proxy { };
  libltnginx = pkg ./libltnginx { };
  liboqs = pkg ./liboqs { };
  nbfc-lantian = pkg ./nbfc-lantian { };
  netboot-xyz = pkg ./netboot-xyz { };
  netns-exec = pkg ./netns-exec { };
  noise-suppression-for-voice = pkg ./noise-suppression-for-voice { };
  onepush = pkg ./onepush { };
  openresty-lantian = pkg ./openresty-lantian {
    inherit liboqs openssl-oqs;
  };
  openssl-oqs = pkg ./openssl-oqs {
    inherit liboqs;
  };
  osdlyrics = pkg ./osdlyrics { };
  phpmyadmin = pkg ./phpmyadmin { };
  phppgadmin = pkg ./phppgadmin { };
  qbittorrent-enhanced-edition = pkg ./qbittorrent-enhanced-edition { };
  qemu-user-static = pkg ./qemu-user-static { };
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

} // (if (!ci) then rec {
  # These packages aren't built on CI
  linux-xanmod-lantian = pkg ./linux-xanmod-lantian { };
  linux-xanmod-lantian-config = linux-xanmod-lantian.configfile;
  openj9-ibm-semeru = pkgs.recurseIntoAttrs (pkg ./openj9-ibm-semeru { });

} else { }) // (if inputs == null then { } else rec {
  # These packages require nix flakes support
  keycloak-lantian = pkg ./keycloak-lantian {
    inherit (inputs) keycloak-lantian;
  };
})
