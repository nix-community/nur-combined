let group = import ../groups/dns.nix;
in {
  name = "stubby";
  uid = 2001;
  inherit group;
  extraGroups = [ ];
}
