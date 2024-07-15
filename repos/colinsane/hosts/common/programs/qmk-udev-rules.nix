{ config, lib, ... }:
let
  cfg = config.sane.programs.qmk-udev-rules;
in
{
  sane.programs.qmk-udev-rules.sandbox.enable = false;
  services.udev.packages = lib.mkIf cfg.enabled [ cfg.package ];
}

