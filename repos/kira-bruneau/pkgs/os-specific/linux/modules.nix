pkgs: final: prev:

with final;

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  xpadneo = callPackage ./xpadneo { };
}
