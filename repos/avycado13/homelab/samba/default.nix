{
  config,
  lib,
  pkgs,
  ...
}:
let
  hl = config.homelab;
  cfg = hl.samba;
  smb_networks = [
    "10.0.0.0/24"
    "100.64.0.0/10"
    "fd7a:115c:a1e0::/48"
  ];
  timeMachineShares = lib.filterAttrs (_name: share: share.timeMachine) cfg.shares;
in
{
  options.homelab.samba = {
    enable = lib.mkEnableOption {
      description = "Samba shares for the homelab";
    };
    example = lib.mkOption {
      default = lib.attrsets.mapAttrs (
        _name: value: _name:
        value.settings
      ) cfg.shares;
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = /dev/null;
      description = "Path to samba password file";
    };
    globalSettings = lib.mkOption {
      description = "Global Samba parameters";
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "browseable" = "yes";
        "writeable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
    commonSettings = lib.mkOption {
      description = "Parameters applied to each share";
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "security" = "user";
        "invalid users" = [ "root" ];
      };
      apply =
        old:
        lib.attrsets.mergeAttrsList [
          {
            "preserve case" = "yes";
            "short preserve case" = "yes";
            "browseable" = "yes";
            "writeable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "valid users" = hl.user;
            "fruit:aapl" = "yes";
            "fruit:copyfile" = "yes";
            "vfs objects" = "catia fruit streams_xattr";
          }
          old
        ];
    };
    shares = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.path;
            };

            timeMachine = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Advertise this share as an Apple Time Machine destination.";
            };
          };
        }
      );

      example = lib.literalExpression ''
        {
          tm_share = {
            path = "/mnt/tm_share";
            timeMachine = true;
          };

          Media = {
            path = "/mnt/Media";
          };
        }
      '';

      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    # To be discoverable with windows
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    environment.systemPackages = [ config.services.samba.package ];

    systemd.tmpfiles.rules = map (x: "d ${x.path} 0775 ${hl.user} ${hl.group} - -") (
      lib.attrValues cfg.shares
    );

    system.activationScripts.samba_user_create = ''
      smb_password=$(cat "${cfg.passwordFile}")
      echo -e "$smb_password\n$smb_password\n" | ${lib.getExe' pkgs.samba "smbpasswd"} -a -s ${hl.user}
    '';

    networking.firewall = {
      allowedTCPPorts = [ 5357 ];
      allowedUDPPorts = [ 3702 ];
    };

    services.samba = {
      enable = true;
      package = pkgs.samba4Full;
      usershares.enable = true;
      openFirewall = true;
      settings = {
        global = lib.mkMerge [
          {
            workgroup = lib.mkDefault "WORKGROUP";
            "server string" = lib.mkDefault config.networking.hostName;
            "netbios name" = lib.mkDefault config.networking.hostName;
            "security" = lib.mkDefault "user";
            "invalid users" = [ "root" ];
            "hosts allow" = lib.mkDefault (lib.strings.concatStringsSep " " smb_networks);
            "guest account" = lib.mkDefault "nobody";
            "map to guest" = lib.mkDefault "bad user";
            "passdb backend" = lib.mkDefault "tdbsam";
            "deadtime" = 30;
            "use sendfile" = "yes";
          }
          cfg.globalSettings
        ];
      }
      // builtins.mapAttrs (_name: value: value // cfg.commonSettings) cfg.shares;
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
          <type>_smb._tcp</type>
          <port>445</port>
          </service>
          ${lib.concatMapStrings (name: ''
            <service>
              <type>_adisk._tcp</type>
              <txt-record>dk0=adVN=${name},adVF=0x82</txt-record>
              <txt-record>sys=waMa=0,adVF=0x100</txt-record>
            </service>
          '') (lib.attrNames timeMachineShares)}
          </service-group>
        '';
      };
    };
  };
}
