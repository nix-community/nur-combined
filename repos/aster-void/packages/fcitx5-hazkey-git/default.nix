{pkgs}: let
  hazkeyStable = import ../fcitx5-hazkey {inherit pkgs;};
in
  pkgs.callPackage ./package.nix {
    protobuf = pkgs.protobuf_21; # protobuf 3.2.1
    llama-cpp = pkgs.llama-cpp-vulkan;
    inherit hazkeyStable;
  }
