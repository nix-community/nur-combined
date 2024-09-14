# Adapted from https://github.com/kmonad/kmonad/blob/master/nix/nixos-module.nix
#
# Copyright © David Janssen and Andrew Kvalheim
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

{ config, lib, pkgs, ... }:

let
  inherit (builtins) attrValues listToAttrs;

  cfg = config.services.kmonad;

  package = pkgs.kmonad;

  # Per-keyboard options:
  keyboard = { name, ... }: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        example = "laptop-internal";
        description = "Keyboard name.";
      };

      device = lib.mkOption {
        type = lib.types.path;
        example = "/dev/input/by-id/some-dev";
        description = "Path to the keyboard's device file.";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "openrazer" ];
        description = ''
          Extra permission groups to attach to the KMonad instance for
          this keyboard.
          Since KMonad runs as an unprivileged user, it may sometimes
          need extra permissions in order to read the keyboard device
          file.  If your keyboard's device file isn't in the input
          group you'll need to list its group in this option.
        '';
      };

      compose = {
        key = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "ralt";
          description = "The (optional) compose key to use.";
        };

        delay = lib.mkOption {
          type = lib.types.int;
          default = 5;
          description = "The delay (in milliseconds) between compose key sequences.";
        };
      };

      fallthrough = lib.mkEnableOption "Reemit unhandled key events.";

      allowCommands = lib.mkEnableOption "Allow keys to run shell commands.";

      config = lib.mkOption {
        type = lib.types.lines;
        default = ''
          (defsrc a)
          (deflayer default a)
          ;; Missing kmonad.keyboard.<name>.config
        '';
        description = ''
          Keyboard configuration excluding the defcfg block.
        '';
      };
    };

    config = {
      name = lib.mkDefault name;
    };
  };

  # Create a complete KMonad configuration file:
  mkCfg = keyboard:
    let defcfg = ''
      (defcfg
        input  (device-file "${keyboard.device}")
        output (uinput-sink "kmonad-${keyboard.name}")
    '' +
    lib.optionalString (keyboard.compose.key != null) ''
      cmp-seq ${keyboard.compose.key}
      cmp-seq-delay ${toString keyboard.compose.delay}
    '' + ''
        fallthrough ${lib.boolToString keyboard.fallthrough}
        allow-cmd ${lib.boolToString keyboard.allowCommands}
      )
    '';
    in
    pkgs.writeTextFile {
      name = "kmonad-${keyboard.name}.cfg";
      text = defcfg + "\n" + keyboard.config;
      checkPhase = "${cfg.package}/bin/kmonad -d $out";
    };

  # Build a systemd path config that starts the service below when a
  # keyboard device appears:
  mkPath = keyboard: rec {
    name = "kmonad-${keyboard.name}";
    value = {
      description = "KMonad trigger for ${keyboard.device}";
      upheldBy = [ "default.target" ];
      pathConfig.Unit = "${name}.service";
      pathConfig.PathExists = keyboard.device;
    };
  };

  # Build a systemd service that starts KMonad:
  mkService = keyboard: {
    name = "kmonad-${keyboard.name}";
    value = {
      description = "KMonad for ${keyboard.device}";
      script = "${cfg.package}/bin/kmonad ${mkCfg keyboard}";
      serviceConfig.Restart = "no";
      serviceConfig.User = "kmonad";
      serviceConfig.SupplementaryGroups = [ "input" "uinput" ] ++ keyboard.extraGroups;
      serviceConfig.Nice = -20;
    };
  };
in
{
  options.services.kmonad = {
    enable = lib.mkEnableOption "KMonad: An advanced keyboard manager.";

    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      example = "pkgs.haskellPackages.kmonad";
      description = "The KMonad package to use.";
    };

    keyboards = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule keyboard);
      default = { };
      description = "Keyboard configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.groups.uinput = { };
    users.groups.kmonad = { };

    users.users.kmonad = {
      description = "KMonad system user.";
      group = "kmonad";
      isSystemUser = true;
    };

    services.udev.extraRules = ''
      # KMonad user access to /dev/uinput
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    systemd.paths = listToAttrs (map mkPath (attrValues cfg.keyboards));

    systemd.services = listToAttrs (map mkService (attrValues cfg.keyboards));
  };
}
