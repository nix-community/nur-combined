self: super:
let
  nur = super.callPackage ./package.nix {};
in
{
  inherit nur;
}
