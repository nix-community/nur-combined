{ config, lib, ... }:
let
  isArm = lib.strings.hasInfix "aarch" config.nixpkgs.system;
  storage = if isArm then "Storage=volatile" else "Storage=volatile";
  systemMaxUse = if isArm then "SystemMaxUse=64M" else "SystemMaxUse=1G";
  maxRetentionSec =
    if isArm then "MaxRetentionSec=31day" else "MaxRetentionSec=365day";
  extraConfig = ''
    ${storage}
    ${systemMaxUse}
    ${maxRetentionSec}
  '';
in { services.journald = { inherit extraConfig; }; }
