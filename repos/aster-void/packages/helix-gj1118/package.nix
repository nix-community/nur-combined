{system}: let
  rev = "9c5d1f4a5dee8047555423090552f420966d23ec";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
