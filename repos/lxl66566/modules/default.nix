{
  pkgs ? import <nixpkgs> { },
}:

{
  fungi = import ./fungi;
  system76-scheduler-niri = import ./system76-scheduler-niri;
}
