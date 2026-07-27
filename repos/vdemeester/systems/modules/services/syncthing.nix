{ config, lib, pkgs, ... }:

with lib;
let
  # unstable = versionOlder config.system.nixos.release "21.05";
  cfg = config.modules.services.syncthing;
  isCurrentHost = n: v: n != config.networking.hostName;
  devices = {
    wakasu = {
      id = "3P5BRF6-27NH2OX-3ZUI7EZ-BP4KCSE-EF2GMJL-DHUGPP2-OGHIJVO-LAJOMA7";
      addresses = [ "tcp://wakasu.home" "tcp://wakasu.vpn" "tcp://wakasu.sbr.pm" ];
    };
    aomi = {
      id = "XCR6WWB-OZUDGFB-LQPFW73-MV5SPJK-4IGOMA4-IAXON3I-C6OFETL-TPK5FQS";
      addresses = [ "tcp://aomi.vpn" "tcp://aomi.home" "tcp://aomi.sbr.pm" ];
    };
    sakhalin = {
      id = "4TYYG7V-A67D5SN-HMEJCI7-POOZRLL-RNCIE4U-ZYVGTOB-JQ5DOSV-ZCGWUAL";
      addresses = [ "tcp://sakhalin.home" "tcp://sakhalin.vpn" "tcp://sakhalin.sbr.pm" ];
    };
    shikoku = {
      id = "KZMMXRR-UINDQTS-H3TV2W7-EIGOUDI-3LW4ZDG-7PRKDFV-MJ5KUTJ-YG5Y5AI";
      addresses = [ "tcp://shikoku.home" "tcp://shikoku.vpn" "tcp://shikoku.sbr.pm" ];
    };
    kerkouane = {
      id = "IFVRRQ7-KMIOQXP-5YDJXQU-UJXUKHB-7THCSY6-B3NHRNA-ED7IRI7-2JPPKQY";
      addresses = [ "tcp://10.100.0.1" "tcp://kerkouane.vpn" ];
    };
    aion = {
      id = "YORNSGU-UC4IAG5-IWJCD7T-MVPIU7O-AYM36UK-LEHF7AP-CBC4L6C-ZWKUYQF";
      addresses = [ "tcp://aion.home" "tcp://aion.vpn" "tcp://aion.sbr.pm" ];
    };
    # Deprecated
    # naruhodo = {
    #   id = "BKZN3FH-KRP4XRN-XFEVCCG-VANAUJN-YFAUS5Q-WUOLQQ7-II7I6PR-NVJZXQT";
    #   addresses = [ "tcp://naruhodo.vpn" "tcp://naruhodo.home" ];
    # };
    # okinawa = {
    #   id = "2RWT47Z-UGSH4QO-G4W6XN7-3XY722R-ZKGDN5U-4MDGHMA-6SM26QM-7VCQIAZ";
    #   addresses = [ "tcp://okinawa.home" "tcp://okinawa.vpn" "tcp://ok ];
    # };
  };
  deviceNames = builtins.attrNames (filterAttrs isCurrentHost devices);
in
{
  options = {
    modules.services.syncthing = {
      enable = mkEnableOption "Enable syncthing profile";
      guiAddress = mkOption {
        type = types.str;
        default = "127.0.0.1:8384";
        description = ''
          The address to serve the web interface at.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    services.syncthing =
      if (builtins.hasAttr "devices" config.services.syncthing)
      then {
        enable = true;
        user = "vincent";
        dataDir = "/home/vincent/.syncthing";
        configDir = "/home/vincent/.syncthing";
        guiAddress = cfg.guiAddress;
        settings = {
          devices = filterAttrs isCurrentHost devices;
          folders = {
            "/home/vincent/sync" = {
              label = "sync";
              id = "7dshg-r8zr6";
              devices = deviceNames;
            };
            # "/home/vincent/desktop/notes" = {
            #   label = "notes";
            #   id = "q2eld-jylbu";
            #   devices = deviceNames;
            # };
            "/home/vincent/desktop/org" = {
              label = "org";
              id = "sjpsr-xfwdu";
              devices = deviceNames;
            };
	  } // (if (config.networking.hostName != "kerkouane") then {
            "/home/vincent/desktop/documents" = {
              label = "documents";
              id = "oftdb-t5anv";
              devices = deviceNames;
            };
            "/home/vincent/desktop/pictures/screenshots" = {
              label = "screenshots";
              id = "prpsz-azlz9";
              devices = deviceNames;
            };
            "/home/vincent/desktop/pictures/wallpapers" = {
              label = "wallpapers";
              id = "wpiah-ydwwx";
              devices = deviceNames;
            };
          } else {});
        };
      }
      else {
        enable = true;
        user = "vincent";
        dataDir = "/home/vincent/.syncthing";
        configDir = "/home/vincent/.syncthing";
        guiAddress = cfg.guiAddress;
      };
  };
}
