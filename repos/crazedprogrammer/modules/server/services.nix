{ config, pkgs, lib, ... }:

with lib;
with import ./vars.nix;

{
  systemd.services = {
    shittydl = {
      description = "shittydl service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ nodejs-8_x python gcc sqlite ];
      script = ''
        node index.js
      '';

      serviceConfig = {
        User = "shittydl";
        Type = "simple";
        WorkingDirectory = shittydlHome + "/shittydl";
      };
    };
    jamrogue = {
      description = "Jamrogue server service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ nodejs-8_x ];
      script = ''
        node main
      '';

      serviceConfig = {
        User = "jamrogue";
        Type = "simple";
        WorkingDirectory = jamrogueHome + "/jamROGUE/server/dist";
      };
    };
    modmc1 = {
      description = "Modded minecraft server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ jre ];
      script = ''
        java -jar forge-1.11.2-13.20.1.2386-universal.jar -nogui
      '';

      serviceConfig = {
        User = "modmc1";
        Type = "simple";
        WorkingDirectory = modmc1Home + "/modmc1";
      };
    };
    thelounge = {
      description = "The Lounge web IRC client";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      preStart = "ln -sf ${pkgs.writeText "config.js" theloungeConfig} ${theloungeHome}/config.js";
      script = ''
        ${pkgs.thelounge}/bin/lounge start --home ${theloungeHome}
      '';
      serviceConfig = {
        User = "thelounge";
        ProtectHome = "true";
        ProtectSystem = "full";
        PrivateTmp = "true";
      };
    };
    c3i = {
      description = "ComputerCraft build server";
      path = with pkgs; [ (python36.withPackages (ps: [ ps.pystache ])) openjdk gradle git bash which ];
      script = ''
        python3.6 fetch.py
      '';
      startAt = "*-*-* *:00:00";
      serviceConfig = {
        User = "c3i";
        WorkingDirectory = c3iHome + "/c3i";
      };
    };
    kristminer = {
      description = "Krist miner service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ bash cpulimit ];
      script = ''
        ./mine.sh
      '';

      serviceConfig = {
        User = "unp";
        Type = "simple";
        WorkingDirectory = "/home/unp";
      };
    };
#   ccfuse-relay = {
#     description = "CCFuse Relay service";
#     after = [ "network.target" ];
#     wantedBy = [ "multi-user.target" ];
#     path = with pkgs; [ jre ];
#     script = ''
#       java -jar ccfuse/host/build/libs/ccfuse-host-0.1-all.jar --relay ${toString ccfusePort}
#     '';

#     serviceConfig = {
#       User = "ccfuse";
#       Type = "simple";
#       WorkingDirectory = ccfuseHome;
#     };
#   };
#   ccfuse = {
#     description = "CCFuse service";
#     after = [ "network.target" "ccfuse-relay.service" ];
#     wantedBy = [ "multi-user.target" ];
#     path = with pkgs; [ jre eject ];
#     script = ''
#       echo $LD_LIBRARY_PATH
#       java -jar ccfuse/host/build/libs/ccfuse-host-0.1-all.jar --mountpoint cc --channel 0 --host ws://127.0.0.1:${toString ccfusePort}
#     '';
#     environment = { LD_LIBRARY_PATH = "${pkgs.fuse}/lib"; };

#     serviceConfig = {
#       User = "ccfuse";
#       Type = "simple";
#       WorkingDirectory = ccfuseHome;
#     };
#   };
  };
}
