let
  identity = import ../resources/identity.nix;
in
{
  # Containers
  virtualisation.containers.registries.search = [ "docker.io" ];
  virtualisation.docker = { enable = true; enableOnBoot = false; autoPrune.enable = true; };
  virtualisation.podman.enable = true;

  # Virtual machines
  virtualisation.libvirtd.enable = true;

  # Permissions
  users.users.${identity.username}.extraGroups = [ "docker" "libvirtd" "podman" ];
}
