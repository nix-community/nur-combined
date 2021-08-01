{
  # Add your NixOS modules here
  #
  libvirt = ./libvirt.nix;
  vfio = ./vfio.nix;
  virtualisation.nix = ./virtualisation.nix;
}
