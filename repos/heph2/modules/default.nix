{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  atlas = ./services/atlas/atlas.nix;
  pounce = ./services/pounce/pounce.nix;
  bind = ./services/bind/bind.nix;
}
