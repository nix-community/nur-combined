{
  pkgs ? import <nixpkgs> { },
}:

let
  deepseek-harness = pkgs.callPackage ./pkgs/deepseek-harness { };
in
{
  ab-download-manager = pkgs.callPackage ./pkgs/ab-download-manager { };
  alger-music-player = pkgs.callPackage ./pkgs/alger-music-player { };
  baidunetdisk = pkgs.callPackage ./pkgs/baidunetdisk { };
  baidupcs-go = pkgs.callPackage ./pkgs/baidupcs-go { };
  bluez-5_86 = pkgs.callPackage ./pkgs/bluez-5_86 { };
  caddy-naive = pkgs.callPackage ./pkgs/caddy-naive { };
  cargo-pretty = pkgs.callPackage ./pkgs/cargo-pretty { };
  inherit deepseek-harness;
  dingtalk = pkgs.callPackage ./pkgs/dingtalk { };
  dsh-plugins = pkgs.callPackage ./pkgs/dsh-plugins { inherit deepseek-harness; };
  firefoxpwa-xwayland = pkgs.callPackage ./pkgs/firefoxpwa-xwayland { };
  flutter-rust-bridge-codegen = pkgs.callPackage ./pkgs/flutter-rust-bridge-codegen { };
  gradle-language-server = pkgs.callPackage ./pkgs/gradle-language-server { };
  herdr = pkgs.callPackage ./pkgs/herdr { };
  kelivo = pkgs.callPackage ./pkgs/kelivo { };
  kotlin-lsp = pkgs.callPackage ./pkgs/kotlin-lsp { };
  niri = pkgs.callPackage ./pkgs/niri { };
  peazip-rar = pkgs.callPackage ./pkgs/peazip-rar { };
  r-maple-mono-nf-cn = pkgs.callPackage ./pkgs/r-maple-mono-nf-cn { };
  rea = pkgs.callPackage ./pkgs/rea { };
  rime-lmdg = pkgs.callPackage ./pkgs/rime-lmdg { };
  rime-wanxiang = pkgs.callPackage ./pkgs/rime-wanxiang { };
  sunloginclient = pkgs.callPackage ./pkgs/sunloginclient { };
  yanhekt-autoslides = pkgs.callPackage ./pkgs/yanhekt-autoslides { };
  winboat-unstable = pkgs.callPackage ./pkgs/winboat-unstable { };
  xwayland-satellite = pkgs.callPackage ./pkgs/xwayland-satellite { };
  yesplaymusic = pkgs.callPackage ./pkgs/yesplaymusic { };

  homeModules = import ./home-modules;
  nixosModules = import ./nixos-modules;
}
