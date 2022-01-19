{ pkgs
, stdenv
, lib
, fetchFromGitHub
, buildLinux
, ...
} @ args:

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
let
  version = "5.16.1";
  release = "1";
in
buildLinux {
  inherit stdenv lib version;
  src = fetchFromGitHub {
    owner = "xanmod";
    repo = "linux";
    rev = "${version}-xanmod${release}";
    sha256 = "sha256-0p1gcKJ5wmm6l8AWjBFjw98axJEvcyT4o7EhhoJeRoI=";
  };
  modDirVersion = "${version}-xanmod${release}-lantian";

  structuredExtraConfig = import ./config.nix args;

  kernelPatches = [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper
  ] ++ (builtins.map
    (name: {
      inherit name;
      patch = ./patches + "/${name}.patch";
    }) [
    "0001-drm-i915-gvt-Add-virtual-option-ROM-emulation"
    "0002-qcserial"
    "0003-intel-drm-use-max-clock"
    "0004-hp-omen-fourzone"
    "0005-cjktty"
    "0006-uksm"
    "0007-vfio-pci-d3cold"
  ]);

  extraMeta.broken = !stdenv.hostPlatform.isx86_64;
}
