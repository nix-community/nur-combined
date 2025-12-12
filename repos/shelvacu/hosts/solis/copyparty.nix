{ config, vacuModules, ... }:
let
  cfg = config.vacu.copyparties.solis;
in
{
  imports = [ vacuModules.copyparty-solis ];
  vacu.copyparties.solis.configureFileServer = true;

  # groups.transmission.members = [ cfg.mainUser ];
  systemd.tmpfiles.settings."10-whatever"."/xstore/torrents"."A+".argument = "user:${cfg.mainUser}:rx,default:user:${cfg.mainUser}:rx";
}
