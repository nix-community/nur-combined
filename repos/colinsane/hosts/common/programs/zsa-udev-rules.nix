{ config, lib, ... }:
let
  cfg = config.sane.programs.zsa-udev-rules;
in
{
  sane.programs.zsa-udev-rules.sandbox.enable = false;
  services.udev.packages = lib.mkIf cfg.enabled [ cfg.package ];
}
