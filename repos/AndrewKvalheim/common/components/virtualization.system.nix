let
  identity = import ../resources/identity.nix;
in
{
  # Docker
  virtualisation.docker = { enable = true; enableOnBoot = false; autoPrune.enable = true; };
  users.extraGroups.docker.members = [ identity.username ];

  # Podman
  virtualisation.containers.registries.search = [ "docker.io" ];
  virtualisation.podman = { enable = true; autoPrune.enable = true; };
  users.extraGroups.podman.members = [ identity.username ];

  # VirtualBox
  virtualisation.virtualbox.host = { enable = true; };
  users.extraGroups.vboxusers.members = [ identity.username ];
}
