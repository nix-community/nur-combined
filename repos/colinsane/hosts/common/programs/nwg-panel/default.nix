# nwg-panel: a wayland status bar (like waybar, etc)
# documentation is in the GitHub Wiki:
# - <https://github.com/nwg-piotr/nwg-panel/wiki/Configuration>
#
# interactively configure with: `nwg-panel-config`
# ^ note that this may interfere with the `nwg-panel` service
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.nwg-panel;
  mkEnableOption' = default: description: lib.mkOption {
    type = lib.types.bool;
    inherit default description;
  };
  i3ipc = pkgs.python3Packages.i3ipc.overridePythonAttrs {
    # XXX(2025-08-25): tests are broken; remove once fixed
    doCheck = false;
  };
  playerctl = pkgs.playerctl.overrideAttrs (upstream: {
    patches = (upstream.patches or []) ++ [
      (pkgs.fetchpatch {
        # playerctl, when used as a library, doesn't expect its user to `unref` it inside a glib signal.
        # nwg-panel does this though, and then segfaults.
        # playerctl project looks dead as of 2024/06/19, no hope for upstreaming this.
        # - <https://github.com/altdesktop/playerctl/>
        # TODO: consider removing this if nwg-panel code is changed to not trigger this.
        # - <https://github.com/nwg-piotr/nwg-panel/issues/233>
        name = "dbus_name_owner_changed_callback: acquire a ref on the manager before using it";
        url = "https://git.uninsane.org/colin/playerctl/commit/bbcbbe4e03da93523b431ffee5b64e10b17b4f9f.patch";
        hash = "sha256-l/w+ozga8blAB2wtEd1SPBE6wpHNXWk7NrOL7x10oUI=";
      })
    ];
  });
in
{
  sane.programs.torch-toggle = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "torch-toggle";
      pkgs = [ "brightnessctl" ];
      srcRoot = ./.;
    };

    suggestedPrograms = [
      "brightnessctl"
    ];
    sandbox = config.sane.programs.brightnessctl.sandbox;
  };

  sane.programs.nwg-panel = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          clockFontSize = mkOption {
            type = types.int;
            # what looks good:
            # - 15px on moby
            # - 24px on lappy
            # there's about 10px padding total around this (above + below)
            default = lib.min 24 (cfg.config.height - 11);
          };
          fontSize = mkOption {
            type = types.int;
            default = 16;
          };
          height = mkOption {
            type = types.int;
            default = 40;
            description = ''
              height of the top bar in px.
            '';
          };
          locker = mkOption {
            type = types.str;
            default = config.sane.programs.swayidle.config.actions.lock.service;
            description = ''
              service to start which can lock the screen
            '';
          };
          torch = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              device name for the torch (flashlight), if any.
              find with `brightnessctl -l`
            '';
            example = "white:flash";
          };
          battery = mkEnableOption' true "display battery status";
          brightness = mkEnableOption' true "display backlight level and slider";
          mediaTitle = mkEnableOption' true "display title of current song/media";
          mediaPrevNext = mkEnableOption' true "display prev/next button in media";
          sysload = mkEnableOption' true "display system load info (cpu/memory)";
          windowIcon = mkEnableOption' true "display icon of active window";
          windowTitle = mkEnableOption' true "display title of active window";
          workspaceNumbers = mkOption {
            type = types.listOf types.str;
            default = [
              # TODO: workspace 10 should be rendered as "TV"
              "1" "2" "3" "4" "5" "6" "7" "8" "9" "10"
            ];
            description = ''
              workspaces to monitor
            '';
          };
          workspaceHideEmpty = mkOption {
            type = types.bool;
            default = true;
          };
        };
      };
    };

    packageUnwrapped = (pkgs.nwg-panel.override {
      inherit playerctl;
      python3Packages = pkgs.python3Packages // {
        inherit i3ipc;
      };
    }).overrideAttrs (base: {
      # patches = (base.patches or []) ++ lib.optionals (!cfg.config.mediaPrevNext) [
      #   ./playerctl-no-prev-next.diff
      # ];
      patches = (base.patches or []) ++ [
        (pkgs.fetchpatch {
          # upstreaming: <https://github.com/nwg-piotr/nwg-panel/pull/309>
          url = "https://git.uninsane.org/colin/nwg-panel/commit/a714e4100c409feb02c454874d030d192bfb0ae5.patch";
          name = "playerctl: add settings to control which elements are displayed";
          hash = "sha256-OofS46wAI3EDE3JbYs/Nn+Vkw9TP1mwSFvk+vBERg2s=";
        })
      ];

      # - disable the drop-down chevron by the controls.
      #   it's precious space on moby, doesn't do much to help on lappy either.
      # - disable brightness indicator for same reason.
      # - *leave* the volume indicator: one *could* remove it, however on desko that would leave the controls pane empty
      #   making the dropdown inaccessible
      # also, remove padding from the items. i can manage that in css and the python padding prevents that.
      postPatch = (base.postPatch or "") + ''
        substituteInPlace nwg_panel/modules/controls.py --replace-fail \
          'self.box.pack_start(box, False, False, 6)' \
          'self.box.pack_start(box, False, False, 0)'

        substituteInPlace nwg_panel/modules/controls.py --replace-fail \
          'box.pack_start(self.pan_image, False, False, 4)' \
          '# box.pack_start(self.pan_image, False, False, 0)'
        substituteInPlace nwg_panel/modules/controls.py --replace-fail \
          'box.pack_start(self.bri_image, False, False, 4)' \
          '# box.pack_start(self.bri_image, False, False, 0)'

        substituteInPlace nwg_panel/modules/controls.py --replace-fail \
          'box.pack_start(self.vol_image, False, False, 4)' \
          'box.pack_start(self.vol_image, False, False, 0)'
      '';

      # XXX(2024/06/13) the bluetooth stuff doesn't cross compile, so disable it
      propagatedBuildInputs = lib.filter (p: p.pname != "pybluez") base.propagatedBuildInputs;

      strictDeps = true;
    });

    suggestedPrograms = [
      "brightnessctl"
      "pactl"  # pactl required by `per-app-volume` component.
    ] ++ lib.optionals (cfg.config.torch != null) [
      "torch-toggle"
    ];

    fs.".config/nwg-panel/style.css".symlink.target = pkgs.replaceVars ./style.css {
      inherit (cfg.config) fontSize clockFontSize;
    };
    fs.".config/nwg-panel/common-settings.json".symlink.target = ./common-settings.json;
    fs.".config/nwg-panel/config".symlink.target = pkgs.writers.writeJSON "config" (import ./config.nix {
      inherit (cfg.config) locker height mediaPrevNext windowIcon windowTitle workspaceHideEmpty workspaceNumbers;
      # component order matters, mostly for the drop-down.
      # default for most tools (e.g. swaync) is brightness control above volume.
      controlsSettingsComponents =
        lib.optionals cfg.config.brightness [
          "brightness"
        ] ++ [
          "volume"
          # "per-app-volume"
        ] ++ lib.optionals cfg.config.battery [
          "battery"
        ]
      ;
      controlsSettingsCustomItems = lib.optionals (cfg.config.torch != null) [
        {
          name = "Torch";
          # icons: find them in /etc/profiles/per-user/colin/share/icons
          # display-brightness-symbolic, keyboard-brightness-symbolic, night-light-symbolic
          icon = "display-brightness-symbolic";
          cmd = "torch-toggle ${cfg.config.torch}";
        }
      ];
      modulesRight = [
        "playerctl"
      ] ++ lib.optionals cfg.config.sysload [
        "executor-sysload"
      ];
      playerctlChars = if cfg.config.mediaTitle then 60 else 0;
    });

    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistSystemctl = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistMpris.controlPlayers = true;
    sandbox.whitelistDbus.user.call."org.erikreider.swaync.cc" = "*";
    sandbox.extraPaths = [
      "/sys/class/backlight"
      "/sys/class/leds"  #< for torch/flashlight on moby
      "/sys/class/power_supply"  #< for the battery indicator
      "/sys/devices"
    ];
    sandbox.extraRuntimePaths = [ "sway" ];
    sandbox.keepPidsAndProc = true;  #< nwg-panel restarts itself on display dis/connect, by killing all other instances (TODO: fix to just exit on display attach?)

    services.nwg-panel = {
      description = "nwg-panel status/topbar for wayland";
      partOf = [ "graphical-session" ];

      # to debug styling, run with GTK_DEBUG=interactive
      # N.B.: G_MESSAGES_DEBUG=all causes the swaync icon to not render
      # command = "env G_MESSAGES_DEBUG=all nwg-panel";
      # XXX: try `nwg-panel & ; kill $$`. the inner nwg-panel doesn't die (without sane-die-with-parent), and hence the service would be prone to maintaining _multiple_ bars.
      command = "nwg-panel";
    };
  };
}
