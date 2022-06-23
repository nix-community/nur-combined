{ pkgs
, stdenv
, lib
, fetchFromGitHub
, buildLinux
, ...
} @ args:

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
let
  version = "5.18.6";
  release = "1";
in
buildLinux {
  inherit stdenv lib version;
  src = fetchFromGitHub {
    owner = "xanmod";
    repo = "linux";

    # Temporary change since 5.18.6 isn't tagged yet
    # rev = "${version}-xanmod${release}";
    rev = "95f1b63621ed2a58f08a51f0e17357fdeddc81d2";

    sha256 = "sha256-hMPnV0urvamhtT8JJH0k+v3YtIDrCqjOR7PjgGL9E+8=";
  };
  modDirVersion = "${version}-xanmod${release}-lantian";

  structuredExtraConfig = import ./config.nix args;

  kernelPatches = [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper
  ] ++ (builtins.map
    (name: {
      inherit name;
      patch = ./patches + "/${name}";
    })
    (builtins.attrNames (builtins.readDir ./patches)));

  extraMeta.broken = !stdenv.hostPlatform.isx86_64;
}
