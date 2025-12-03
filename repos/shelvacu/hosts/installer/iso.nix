{ modulesPath, ... }:
{
  imports = [
    ./common
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  # isoImage.isoBaseName = "nixos-shel-installer";
}
