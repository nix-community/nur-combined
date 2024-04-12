{ pkgs, ... }:

let
  inherit (pkgs.fishPlugins) tide;

in
{
  plugins = [
    {
      name = "tide";
      src = tide.src;
    }
  ];
}
