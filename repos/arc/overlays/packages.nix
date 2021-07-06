self: super: let
  arc = import ../canon.nix { inherit self super; };
in arc.super.arc.packages.extendWith super // arc.super.arc.build
