{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gmid;
  vhostToConfig = whostName: vhostAttrs: ''
    ${vhostName} ${builtins.concatStringsSep " " whostAttrs.serverAliases} {
      ${vhostAttrs.extraConfig}
    }
    '';
  configFile = pkgs.writeText "gmid.conf" (builtins.concatStringsSep "\n"
    ([ cfg.config ] ++ (mapAttrsToList vhostToConfig cfg.virtualHosts)));
in
{
  options = {
    services.gmid = {
      
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
        Whether to enable Gmid
        '';
      };

      config = mkOption {
        default = "";
        example = ''
           server "example.com" {
                  cert "/etc/ssl/example.com.crt"
                  key  "/etc/ssl/private/example.com.key"
                  root "/var/gemini/example.com"
           }
        '';
        type = types.lines;
        description = ''
          Verbatim gmid config to use.
        '';
      };

      virtualHosts = mkOption {
        type = types.attrsOf (types.submodule (import ./vhost-options.nix {
          inherit config lib;
        }));
        default = { };
        example = literalExpression ''
           server "example.com" {
                  cert "/etc/ssl/example.com.crt"
                  key  "/etc/ssl/private/example.com.key"
                  root "/var/gemini/example.com"
           }
        '';
        description = "Declarative vhost config";
      };

      dataDir = mkOption {
        default = "/var/lib/gmid";
        type = types.path;
        description = '''';        
      };
      
      user = mkOption {
        default = "gmid";
        example = "john";
        type = types.str;
        description = ''
          The name of an existing user account to use to own the gmid server
          process. If not specified, a default user will be created.
        '';
      };

      group = mkOption {
        default = "gmid";
        example = "users";
        type = types.str;
        description = ''
          Group to own the gmid process.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.gmid;
        defaultText = "pkgs.gmid";
      };
                  
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra configuration";
      };      
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gmid = {
      description = "gmid gemini server";    
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy  = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.gmid}/bin/gmid -c ${configFile}";
        Restart = "always";
        RuntimeDirectory = "gmid";
        RuntimeDirectoryMode = "0700";
      };
    };
    
    users.users = optionalAttrs (cfg.user == "gmid") {
      gmid = {
        description = "gmid server daemon owner";
        group = cfg.group;
        #        uid = config.ids.uids.gmid;
        isSystemUser = true;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = optionalAttrs (cfg.user == "gmid") {
#      gmid.gid = config.ids.gids.gmid;
    };
  };
}
