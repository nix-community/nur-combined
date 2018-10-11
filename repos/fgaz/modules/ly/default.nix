# WARNING: this causes a segafault and I don't know why

{ config, lib, pkgs, ... }:

with lib;

let

  dmcfg = config.services.xserver.displayManager;

  cfg = dmcfg.ly;

  lyConfig = pkgs.writeText "config.ini"
    ''
      #xauth_path ${dmcfg.xauthBin}
      #default_xserver ${dmcfg.xserverBin}
      #xserver_arguments ${toString dmcfg.xserverArgs}
      #sessiondir ${dmcfg.session.desktops}/share/xsessions
      #login_cmd exec ${pkgs.runtimeShell} ${dmcfg.session.wrapper} "%session"
      #halt_cmd ${config.systemd.package}/sbin/shutdown -h now
      #reboot_cmd ${config.systemd.package}/sbin/shutdown -r now
      #logfile /dev/stderr

      [box_main]

      # xsessions path
      #xsessions=${dmcfg.session.desktops}/share/xsessions

      x_cmd=${dmcfg.xserverBin}
      x_cmd_setup=${dmcfg.setupCommands}
      #mcookie_cmd=/usr/bin/mcookie
      #xauthority=.lyxauth
      #path=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/env

      # shutdown is given parameters, do not use an alternative
      # this is here only to allow you to change its location
      shutdown_cmd=${config.systemd.package}/sbin/shutdown

      # reflect this change in ly.service as well
      #console_dev=/dev/console
      #tty=2

      # login and desktop environment fields persistence
      save=0
      load=0
      #save_file=/etc/ly/ly.save

      ${cfg.extraConfig}

    '';

in

{

  ###### interface

  options = {

    services.xserver.displayManager.ly = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Ly as the display manager.
        '';
      };

      defaultUser = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "login";
        description = ''
          The default user to load. If you put a username here you
          get it automatically loaded into the username field, and
          the focus is placed on the password.
        '';
      };

      autoLogin = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Automatically log in as the default user.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration options for SLiM login manager. Do not
          add options that can be configured directly.
        '';
      };

      consoleCmd = mkOption {
        type = types.nullOr types.str;
        default = ''
          ${pkgs.xterm}/bin/xterm -C -fg white -bg black +sb -T "Console login" -e ${pkgs.shadow}/bin/login
        '';
        defaultText = ''
          ''${pkgs.xterm}/bin/xterm -C -fg white -bg black +sb -T "Console login" -e ''${pkgs.shadow}/bin/login
        '';
        description = ''
          The command to run when "console" is given as the username.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.xserver.displayManager.job = {
      execCmd = "exec ${pkgs.ly}/bin/ly";
    };

    environment.systemPackages = [ pkgs.ly ];

    environment.etc."ly/config.ini".source = lyConfig;

  };

}
