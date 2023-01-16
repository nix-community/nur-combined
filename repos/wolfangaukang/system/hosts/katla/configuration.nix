{  config, pkgs, modulesPath, username, ... }:

{
  imports = [
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

  system.stateVersion = "22.11";
}
