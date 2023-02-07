let group = import ../groups/dns.nix;
in {
  name = "pihole";
  uid = 2000;
  inherit group;
  extraGroups = [ ];
}
