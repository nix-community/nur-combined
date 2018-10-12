{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.weechat;
  configFormat = extraConfig: replaceChars ["\n"] ["; "] extraConfig;
  weechatRunCommand = weechat: withMatrix: home: extraConfig: (if withMatrix then ''
      env LUA_CPATH="${pkgs.luaPackages.getLuaCPath pkgs.luaPackages.cjson}" LUA_PATH="${pkgs.luaPackages.getLuaPath pkgs.luaPackages.cjson}" WEECHAT_EXTRA_LIBDIR="${weechat}/share" ''
    else "")
    + ''${weechat}/bin/weechat-headless --daemon --dir "${home}" --run-command "${configFormat extraConfig}"'';
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
      extraConfig = mkOption {
        default = "";
        description = ''
          Commands to be executed upon startup.
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
    launchd.user.agents.weechat = {
      path = [
        (weechat cfg.withSlack cfg.withMatrix)
      ];
      command = (weechatRunCommand (weechat cfg.withSlack cfg.withMatrix) cfg.withMatrix cfg.home cfg.extraConfig);
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
