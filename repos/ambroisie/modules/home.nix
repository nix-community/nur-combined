# Simplify setting home options
{ config, lib, ... }:
let
  actualPath = [ "home-manager" "users" config.my.username "my" "home" ];
  aliasPath = [ "my" "home" ];
in
{
  imports = [
    (lib.mkAliasOptionModule aliasPath actualPath)
  ];
}
