# NixOS module: Codex Desktop Computer Use on niri.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.codexComputerUse;
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
  pluginDir = "opt/codex-desktop/resources/plugins/openai-bundled/plugins/unified-computer-use";
in
{
  imports = [ ./desktop.nix ];

  options.programs.codexComputerUse = {
    enable = mkEnableOption "Codex Desktop with the niri-compatible Linux Computer Use backend";

    package = mkOption {
      type = types.package;
      default = (import ../../default.nix { inherit pkgs; }).codex-desktop;
      defaultText = lib.literalExpression "nur.repos.lihaoze123.codex-desktop";
      description = "Patched Codex Desktop package passed to programs.codexDesktopLinux.";
    };

    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "alice" ];
      description = ''
        Users allowed to drive input. They are added to the `ydotool` group,
        which owns both the ydotool daemon socket and /dev/uinput.
      '';
    };

    patchNiri = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Use the pinned niri source with tiled-window IPC coordinates and the
        input-method keymap synchronization fix.
        Without it, window-relative clicks on tiled windows are refused.
        Requires a full logout/login after switching.
      '';
    };

    agentInput = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Also patch niri with the AgentInput/AgentScreenshot IPC requests (requires
        `patchNiri`). Computer Use then delivers input to the target window's client
        without moving the user's pointer, keyboard focus or active window, keeps menus
        opened by the agent without a seat grab, does not focus windows the agent opens,
        and takes window screenshots without notifications or clipboard changes. The
        backend detects the IPC at runtime and falls back to uinput/ydotool without it.
      '';
    };

    mcpWrapper.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install `codex-computer-use`, a wrapper around the bundled backend
        binary. `codex-computer-use mcp` serves the backend over stdio MCP.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.codexDesktopLinux = {
        enable = true;
        package = cfg.package;
        linuxFeatures = [ "computer-use-linux" ];
      };

      # Keyboard input goes through the ydotool daemon socket.
      programs.ydotool.enable = true;

      # Native pointer input writes to /dev/uinput directly.
      boot.kernelModules = [ "uinput" ];
      services.udev.extraRules = ''
        KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="ydotool", MODE="0660"
      '';

      # AT-SPI accessibility tree for get_app_state / element actions.
      services.gnome.at-spi2-core.enable = true;
      programs.dconf.enable = true;
      programs.dconf.profiles.user.databases = [{
        settings."org/gnome/desktop/interface".toolkit-accessibility = true;
      }];

      users.users = lib.genAttrs cfg.users (_: { extraGroups = [ "ydotool" ]; });
    }

    (mkIf cfg.patchNiri {
      programs.niri.package = pkgs.callPackage ../../pkgs/niri-patched {
        inherit (cfg) agentInput;
      };
    })

    (mkIf cfg.mcpWrapper.enable {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "codex-computer-use" ''
          # Apps launched through the MCP server open without taking focus
          # (honoured by niri with agentInput).
          export NIRI_AGENT_LAUNCH=1
          exec ${cfg.package}/${pluginDir}/bin/codex-computer-use-linux "$@"
        '')
      ];
    })
  ]);
}
