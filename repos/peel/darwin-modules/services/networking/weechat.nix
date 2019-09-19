{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.weechat;
  
  validPaths = paths: with builtins;
    let check = paths: foldl' (x: y: x && (pathExists y)) true paths;
    in check paths || trace "weechat-config: defined extra config files missing. Configuration will not be applied." false;
  
  weechatConfigure = paths: pkgs.writeScript "weechat-configure" ''
    server_status(){
      launchctl list | grep weechat | head -1 | awk '{ print $2 }'
    }

    write_config(){
      for f in ${strings.escapeShellArgs cfg.extraConfigFiles}; do
        sed 's/^/*/' ''${f} > ''${1}/weechat_fifo_*
      done
    }

    for i in {1..24}; do 
      server_status == 0 \
      && echo "Writing config..." \
      && write_config ''${1} \
      && break \
      || echo "Weechat service not running..." \
      && sleep 5;
    done
  '';
  
  weechat = withSlack : withMatrix: pkgs.weechat.override {
    configure = {availablePlugins,...}: {
      extraBuildInputs = [ pkgs.luaPackages.cjson ];
      plugins =
        with availablePlugins; []
        ++ lib.optionals withSlack [
          (python.withPackages (ps: with ps; [websocket_client xmpppy]))
        ]
        ++ lib.optionals withMatrix [
          lua
        ];
      scripts = []
        ++ lib.optionals withMatrix [ pkgs.weechatScripts.weechat-matrix-bridge ]
        ++ lib.optionals withSlack [ pkgs.weechatScripts.wee-slack ];
    };
  };
in
{
  options = {
    services.weechat = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable weechat relay service.
        '';
      };
      home = mkOption {
        default = "/var/weechat";
        description = ''
          Where weechat configuration is stored.
        '';
      };
      withSlack = mkOption {
        default = false;
        description = ''
          Whether to enable wee-slack plugin.
        '';
      };
      withMatrix = mkOption {
        default = false;
        description = ''
          Whether to enable weechat matrix plugin.
        '';
      };
      extraConfigFiles = mkOption {
        type = types.listOf types.path;
        default = [];
        description = ''
          Paths to file containing commands to be executed upon startup. Executed in provided order.
        '';
      };
      scripts = mkOption {
        default = [];
        example = literalExample "[ pkgs.weechat.wee-slack ]";
        description = ''
          Additional scripts or plugins to be installed.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents.weechat-config = mkIf (validPaths cfg.extraConfigFiles) {
      path = [ pkgs.coreutils pkgs.gawk pkgs.gnugrep ];
      command = "${weechatConfigure cfg.extraConfigFiles} ${cfg.home}";
      serviceConfig.ProcessType = "Background";
      serviceConfig.KeepAlive.OtherJobEnabled."org.nixos.weechat" = true;
    };
    launchd.user.agents.weechat = {
      path = [
        (weechat cfg.withSlack cfg.withMatrix)
      ];
      environment = {
        LANG = "en_US.utf8";
        LC_ALL = "en_US.utf8";
        WEECHAT_EXTRA_LIBDIR = "${weechat cfg.withSlack cfg.withMatrix}/share";
      } // optionalAttrs (cfg.withMatrix) {
        LUA_CPATH = "${pkgs.luaPackages.getLuaCPath pkgs.luaPackages.cjson}";
        LUA_PATH = "${pkgs.luaPackages.getLuaPath pkgs.luaPackages.cjson}";
      };
      command = "${weechat cfg.withSlack cfg.withMatrix}/bin/weechat-headless --dir ${cfg.home}";
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
    };
  };
}
