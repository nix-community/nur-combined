let group = import ../groups/games.nix;
in {
  name = "csgo";
  uid = 2003;
  inherit group;
  extraGroups = [ ];
}
