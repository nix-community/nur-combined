{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.ma27.weechat;

  mkLinks = assoc: targetDir: pkgs.writeScriptBin "weechat-assocs.sh" ''
    #! ${pkgs.stdenv.shell}
    ${builtins.concatStringsSep "\n" (map ({ scriptType ? "python", drv, name }: ''
      DIR="${targetDir}/${scriptType}/autoload/"
      mkdir -p $DIR
      ln -sf ${drv}/share/${name} $DIR/${name}
    '') assoc)}
  '';

  myChat = mkLinks cfg.scripts;

  weechatBin = let target = "$HOME/.cache/nix-weechat"; in pkgs.writeScriptBin "weechat" ''
    #! ${pkgs.stdenv.shell} -e

    export TARGET_DIR=${target}
    if [ ! -d $TARGET_DIR ]; then
      mkdir -p $TARGET_DIR
    fi

    ${myChat target}/bin/weechat-assocs.sh

    ${builtins.concatStringsSep "\n" (mapAttrsToList (key: value: "ln -sf ${value} $TARGET_DIR/${key}.conf") cfg.extraConfigs)}

    exec ${pkgs.weechat}/bin/weechat -d $TARGET_DIR
  '';
in
{
  options.ma27.weechat = {
    enable = mkEnableOption "Personal WeeChat configuration";

    useInScreen = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Creates a user unit in systemd named `weechat-screen.service` which runs weechat in
        a screen session managed by systemd.
      '';
    };

    sec = mkOption {
      type = types.path;
      description = ''
        Store path which points to `sec.conf` for weechat.
      '';
    };

    irc = mkOption {
      type = types.path;
      description = ''
        Store path which points to `irc.conf` for weechat.
      '';
    };

    mainConfig = mkOption {
      type = with types; nullOr path;
      default = null;
      description = "Store path to `weechat.conf` (null by default if weechat should generate a new one).";
    };

    bufList = mkOption {
      type = with types; nullOr path;
      default = null;
      description = "Store path to `buflist.conf` (null by default if weechat should generate a new one).";
    };

    plugins = mkOption {
      type = types.path;
      description = "Store path which points to `plugins.conf` for weechat.";
    };

    extraConfigs = mkOption {
      type = with types; attrsOf path;
      default = {};
      example = literalExample ''
        { jabber = ./jabber.conf }
      '';
      description = ''
        Associations for ~/.cache/nix-weechat files:

        The expression

          { jabber = ./jabber.conf }

        moves the store path of `./jabber.conf` to `~/.cache/nix-weechat/jabber.conf`.
      '';
    };

    scripts = mkOption {
      type = with types; listOf (attrsOf (either string package));
      description = "Extra links for the script";
      default = [];
      example = literalExample ''
        [
          { drv = any-package; name = "script-target.ext"; scriptType = "python"; }
        ]
      '';
    };

    extraScreenArgs = mkOption {
      type = with types; listOf str;
      default = [];
      description = "Extra arguments for `screen -Dm` call to start weechat.";
    };

    user = mkOption {
      type = types.str;
      description = "User to run the service.";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run the service.";
    };
  };

  config = mkIf cfg.enable {
    ma27.weechat.extraConfigs = { inherit (cfg) plugins irc sec; }
      // optionalAttrs (cfg.bufList != null) { buflist = cfg.bufList; }
      // optionalAttrs (cfg.mainConfig != null) { weechat = cfg.mainConfig; };

    systemd.services.weechat-screen = mkIf cfg.useInScreen {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      environment.TERM = "xterm-256color";

      script = ''
        exec ${pkgs.screen}/bin/screen -Dm \
          ${concatStringsSep " " cfg.extraScreenArgs} \
          -S weechat \
          ${weechatBin}/bin/weechat
      '';

      serviceConfig = {
        RemainAfterExit = "yes";
        KillMode = "none";
        User = cfg.user;
        Group = cfg.group;
      };
    };

    environment.systemPackages = [ pkgs.screen weechatBin ];
  };
}
