{ modulesPath, ... }:
{
  imports = [
    ./common
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];
}
