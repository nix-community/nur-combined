{ pkgs, lib, inputs, modulesPath, users, ... }:

let
  username = builtins.elemAt users 0;

in
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl

    "${modulesPath}/profiles/minimal.nix"
  ];

  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    wslConf.automount.root = "/mnt";

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;
  };

  # Enable nix flakes
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "22.11";
}
