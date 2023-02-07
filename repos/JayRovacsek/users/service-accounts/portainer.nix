let group = import ../groups/portainer.nix;
in {
  name = "portainer";
  uid = 2002;
  inherit group;
  extraGroups = [ "docker" ];
}
