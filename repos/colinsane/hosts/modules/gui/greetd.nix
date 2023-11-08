# greetd source/docs:
# - <https://git.sr.ht/~kennylevinsen/greetd>
{ config, lib, pkgs, ... }:

let
  systemd-cat = "${pkgs.systemd}/bin/systemd-cat";
  runWithLogger = identifier: cmd: pkgs.writeShellScriptBin identifier ''
    echo "launching ${identifier}..." | ${systemd-cat} --identifier=${identifier}
    ${cmd} 2>&1 | ${systemd-cat} --identifier=${identifier}
  '';
  cfg = config.sane.gui.greetd;
in
{
  options = with lib; {
    sane.gui.greetd.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.gui.greetd.session.command = mkOption {
      type = types.str;
      description = ''
        name to use for the default session in syslog.
      '';
    };
    sane.gui.greetd.session.name = mkOption {
      default = "greetd-session";
      type = types.str;
      description = "name of session to use in logger";
    };
    sane.gui.greetd.session.user = mkOption {
      default = null;
      type = types.nullOr types.str;
    };

    # helpers for common things to layer on top of greetd
    sane.gui.greetd.sway.enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        use sway as a wayland compositor in which to host a graphical greeter like gtkgreet, phog, etc.
      '';
    };
    sane.gui.greetd.sway.greeterCmd = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        command for sway to `exec` that provides the actual graphical greeter.
      '';
    };
    sane.gui.greetd.sway.gtkgreet.enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        have sway launch gtkgreet instead of directly presenting a desktop.
      '';
    };
    sane.gui.greetd.sway.gtkgreet.session.command = mkOption {
      type = types.str;
      description = ''
        command for gtkgreet to execute on successful authentication.
      '';
    };
    sane.gui.greetd.sway.gtkgreet.session.name = mkOption {
      type = types.str;
      description = ''
        name to use for the default session in syslog and in the gtkgreet menu.
        note that this `sessionName` will become a binary on the user's PATH.
      '';
    };
    sane.gui.greetd.sway.gtkgreet.session.user = mkOption {
      type = types.str;
      default = "colin";
      description = ''
        name of user which one expects to login as.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.sway.enable {
      sane.gui.greetd.session = if cfg.sway.greeterCmd != null then {
        name = "sway-as-greeter";
        command = let
          swayAsGreeterConfig = pkgs.writeText "sway-as-greeter-config" ''
            exec ${cfg.sway.greeterCmd}
          '';
        in "${pkgs.sway}/bin/sway --debug --config ${swayAsGreeterConfig}";
      } else {
        name = "sway";
        user = lib.mkDefault "colin";
        command = "${pkgs.sway}/bin/sway --debug";
      };
    })
    (lib.mkIf cfg.sway.gtkgreet.enable (
      let
        inherit (cfg.sway.gtkgreet) session;
        sessionProvider = runWithLogger session.name session.command;
      in {
        # gtkgreet shows the --command argument in the UI
        # - so we want it to look nice (not a /nix/store/... path)
        # - to do that we put it in the user's PATH.
        sane.gui.greetd.sway.greeterCmd = "${pkgs.greetd.gtkgreet}/bin/gtkgreet --layer-shell --command ${session.name}";
        users.users.${session.user}.packages = [ sessionProvider ];
      }
    ))

    {
      services.greetd = {
        enable = true;

        # i could have gtkgreet launch the session directly: but stdout/stderr gets dropped
        # settings.default_session.command = cfg.session.command;

        # wrapper to launch with stdout/stderr redirected to system journal.
        settings.default_session.command = let
          launchWithLogger = runWithLogger cfg.session.name cfg.session.command;
        in "${launchWithLogger}/bin/${cfg.session.name}";
      };

      # persisting fontconfig & mesa_shader_cache improves start time by ~5x
      users.users.greeter.home = "/var/lib/greeter";
      sane.persist.sys.byStore.plaintext = [
        { user = "greeter"; group = "greeter"; path = "/var/lib/greeter/.cache/fontconfig"; }
        { user = "greeter"; group = "greeter"; path = "/var/lib/greeter/.cache/mesa_shader_cache"; }
      ];
    }
  ]);
}
