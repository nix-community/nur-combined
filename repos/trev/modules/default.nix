{
  nixpkgs ? <nixpkgs>,
}:
{
  overlay = import ./overlay.nix { inherit nixpkgs; };
}
