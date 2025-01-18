let
  identity = import ../resources/identity.nix;
in
{
  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
    daemon.settings = {
      bip = "10.222.222.1/24";
      default-address-pools = [
        { base = "10.222.0.0/17"; size = 24; }
        { base = "fd22:2222:2222::/49"; size = 64; }
      ];
      fixed-cidr = "10.222.128.0/17";
      fixed-cidr-v6 = "fd22:2222:2222:8000::/49";
    };
  };
  users.extraGroups.docker.members = [ identity.username ];

  # Podman
  virtualisation.containers.registries.search = [ "docker.io" ];
  virtualisation.podman = { enable = true; autoPrune.enable = true; };
  users.extraGroups.podman.members = [ identity.username ];

  # VirtualBox
  virtualisation.virtualbox.host = { enable = true; };
  users.extraGroups.vboxusers.members = [ identity.username ];
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # Workaround for NixOS/nixpkgs#363887
}
