let
  flake = builtins.getFlake (toString ./.);
in flake
