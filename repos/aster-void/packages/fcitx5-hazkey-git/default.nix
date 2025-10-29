{pkgs}: let
  hazkeyStable = import ../fcitx5-hazkey {inherit pkgs;};
in
  pkgs.callPackage ./package.nix {
    protobuf = pkgs.protobuf3_21;
    llama-cpp = pkgs.llama-cpp-vulkan;
    inherit hazkeyStable;
  }
