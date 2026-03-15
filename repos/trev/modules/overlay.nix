{
  nixpkgs ? <nixpkgs>,
}:
{
  nixpkgs.overlays = [
    (import ../overlays { inherit nixpkgs; }).default
  ];
}
