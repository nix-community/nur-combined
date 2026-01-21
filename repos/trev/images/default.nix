{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  nix = import ./nix { inherit pkgs; };
  ffmpeg = import ./ffmpeg { inherit pkgs; };
}
