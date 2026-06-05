{ config, lib, ... }:
let
  cfg = config.sane.programs.fuseftp;
in
{
  sane.programs.fuseftp = {
    sandbox.method = null;  #< TODO: sandbox
  };

  system.fsPackages = lib.mkIf cfg.enabled [ cfg.package ];
}
