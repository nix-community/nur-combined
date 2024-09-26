{
  lib,
  pkgs,
}:
lib.makeScope pkgs.newScope (self:
    with self; {
      bluemap = callPackage ./bluemap {};
      bluemap-marker-manager = callPackage ./bluemap-marker-manager {};
      bluemap-offline-player-markers = callPackage ./bluemap-offline-player-markers {};
      discordsrv = callPackage ./discordsrv {};
      dynmap = callPackage ./dynmap {};
      harbor = callPackage ./harbor {};
      paper-tweaks = callPackage ./paper-tweaks {};
      simple-voice-chat = callPackage ./simple-voice-chat {};
    })
