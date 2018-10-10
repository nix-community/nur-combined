{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.weechat;
  weechatRunCommand = weechat: withMatrix: home: (if withMatrix then ''
      env LUA_CPATH="${pkgs.luaPackages.getLuaCPath pkgs.luaPackages.cjson}" LUA_PATH="${pkgs.luaPackages.getLuaPath pkgs.luaPackages.cjson}" WEECHAT_EXTRA_LIBDIR="${weechat}/share" ''
    else "")
      + ''${weechat}/bin/weechat-headless --daemon -d "${home}"'';
  weechat = withSlack : withMatrix: pkgs.weechat.override {
    extraBuildInputs = []
      ++ lib.optionals withMatrix [ pkgs.luaPackages.cjson pkgs.weechat-matrix-bridge ]
      ++ lib.optionals withSlack [ pkgs.wee-slack ];
    configure = {availablePlugins,...}: {
      plugins =
        with availablePlugins; []
        ++ lib.optionals withSlack [
          (python.withPackages (ps: with ps; [websocket_client xmpppy]))
        ]
        ++ lib.optionals withMatrix [
          lua
        ] ;
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
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents.weechat = {
      path = [
        (weechat cfg.withSlack cfg.withMatrix)
      ];
      command = (weechatRunCommand (weechat cfg.withSlack cfg.withMatrix) cfg.withMatrix cfg.home);
      environment = {
        LANG = "en_US.utf8";
        LC_ALL = "en_US.utf8";
        WEECHAT_EXTRA_LIBDIR = "${weechat cfg.withSlack cfg.withMatrix}/share";
      };
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
      serviceConfig.WorkingDirectory = "${cfg.home}";
    };
  };
}
