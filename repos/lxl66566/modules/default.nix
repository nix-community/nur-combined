{
  pkgs ? import <nixpkgs> { },
}:

{
  default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./fungi
        ./system76-scheduler-niri
      ];
    };
}
