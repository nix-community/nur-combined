# Simplify setting home options
{ lib, ... }:
let
  actualPath = [ "home-manager" "users" "ambroisie" "my" "home" ];
  aliasPath = [ "my" "home" ];
in
{
  imports = [
    (lib.mkAliasOptionModule aliasPath actualPath)
  ];
}
