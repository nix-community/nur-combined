{ pkgs ? import <nixpkgs> { } }:

rec {
  # pre nur-packages import
  scripts = pkgs.callPackage ./my/scripts { };
  vrsync = pkgs.callPackage ./my/vrsync { };
  vde-thinkpad = pkgs.callPackage ./my/vde-thinkpad { };
  bekind = pkgs.callPackage ../../tools/bekind { };
  go-org-readwise = pkgs.callPackage ../../tools/go-org-readwise { };

  chmouzies.kubernetes = pkgs.callPackage ./chmouzies/kubernetes.nix { };

  # Mine
  ape = pkgs.callPackage ./ape { };
  fhs-std = pkgs.callPackage ./fhs/std.nix { };
  ram = pkgs.callPackage ./ram { };
  systemd-email = pkgs.callPackage ./systemd-email { };

  # Maybe upstream
  athens = pkgs.callPackage ./athens { };
  #gogo-protobuf = pkgs.callPackage ./gogo-protobuf {};
  govanityurl = pkgs.callPackage ./govanityurl { };
  batzconverter = pkgs.callPackage ./batzconverter { };
  prm = pkgs.callPackage ./prm { };
  #protobuild = pkgs.callPackage ./protobuild { };
  rmapi = pkgs.callPackage ./rmapi { };

  operator-tool = pkgs.callPackage ./operator-tooling { };

  manifest-tool = pkgs.callPackage ./manifest-tool { };

  adi1090x-plymouth = pkgs.callPackage ./adi1090x-plymouth { };
}
