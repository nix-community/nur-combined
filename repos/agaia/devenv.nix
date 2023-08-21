{
  pkgs,
  treefmt-nix,
  ...
}: {

  packages = with pkgs; [
    (treefmt-nix.lib.mkWrapper pkgs (import ./treefmt.nix))
  ];
}
