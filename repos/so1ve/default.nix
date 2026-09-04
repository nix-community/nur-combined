{
  pkgs ? import <nixpkgs> { },
}:

{
  ab-download-manager = pkgs.callPackage ./pkgs/ab-download-manager { };
  baidunetdisk = pkgs.callPackage ./pkgs/baidunetdisk { };
  baidupcs-go = pkgs.callPackage ./pkgs/baidupcs-go { };
  deepseek-harness = pkgs.callPackage ./pkgs/deepseek-harness { };
  firefoxpwa-xwayland = pkgs.callPackage ./pkgs/firefoxpwa-xwayland { };
  flutter-rust-bridge-codegen = pkgs.callPackage ./pkgs/flutter-rust-bridge-codegen { };
  herdr = pkgs.callPackage ./pkgs/herdr { };
  niri = pkgs.callPackage ./pkgs/niri { };
  r-maple-mono-nf-cn = pkgs.callPackage ./pkgs/r-maple-mono-nf-cn { };
  yanhekt-autoslides = pkgs.callPackage ./pkgs/yanhekt-autoslides { };
  winboat-unstable = pkgs.callPackage ./pkgs/winboat-unstable { };
  xwayland-satellite = pkgs.callPackage ./pkgs/xwayland-satellite { };

  homeModules = import ./home-modules;
}
