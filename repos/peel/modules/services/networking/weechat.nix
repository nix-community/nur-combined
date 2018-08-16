{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.weechat;
  weechatRunCommand = weechat: withMatrix: home: (if withMatrix then ''
      env LUA_CPATH="${pkgs.luaPackages.getLuaCPath pkgs.luaPackages.cjson}" LUA_PATH="${pkgs.luaPackages.getLuaPath pkgs.luaPackages.cjson}" WEECHAT_EXTRA_LIBDIR="${weechat}/share" ''
    else "")
      + ''${weechat}/bin/weechat -d "${home}"'';
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
      session = mkOption {
        default = "/tmp/tmux-weechat";
        description = ''
          Where store tmux weechat session.
        '';
      };
      portsToOpen = mkOption {
        default = [];
        description = ''
          Relay ports to open.
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
    networking.firewall.allowedTCPPorts = cfg.portsToOpen;
    systemd.user.services."weechat" = {
      enable = true;
      description = "Weechat relay service";
      wantedBy = [ "default.target" ];
      environment = {
        LANG = "en_US.utf8";
        LC_ALL = "en_US.utf8";
        TERM = "${pkgs.rxvt_unicode.terminfo}";
        WEECHAT_EXTRA_LIBDIR = "${weechat cfg.withSlack cfg.withMatrix}/share";
      };
      path = [
        (weechat cfg.withSlack cfg.withMatrix)
        pkgs.tmux
        pkgs.rxvt_unicode.terminfo
      ];
      restartIfChanged = true;
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = "yes";
      serviceConfig.KillMode = "none";
      serviceConfig.WorkingDirectory = "${cfg.home}";
      serviceConfig.ExecStart = "${pkgs.tmux}/bin/tmux -2 -S ${cfg.session} new-session -d -s weechat '${(weechatRunCommand (weechat cfg.withSlack cfg.withMatrix) cfg.withMatrix cfg.home)}'";
      serviceConfig.ExecStop = "${pkgs.tmux}/bin/tmux -S ${cfg.session} kill-session -t weechat";
    };
  };
}
