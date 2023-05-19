{ inputs, materusFlake, ... }:
let
  genHomes = import ./genHomes.nix { inherit inputs; inherit materusFlake; };
in
{ }
  // genHomes "materus"
