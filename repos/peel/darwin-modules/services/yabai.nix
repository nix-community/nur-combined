{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.chunkwm;
in

{
  options = {
    services.yabai.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the yabai window manager.";
    };

    services.yabai.package = mkOption {
      type = types.package;
      example = literalExample "pkgs.yabai";
      description = "This option specifies the yabai package to use.";
    };

    services.yabai.bar.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the yabai window manager.";
    };

    services.yabai.bar.extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''chunkc tiling::rule --owner Emacs --state tile'';
      description = "Additional commands for <filename>yabairc</filename>.";
    };

    services.yabai.extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''chunkc tiling::rule --owner Emacs --state tile'';
      description = "Additional commands for <filename>yabairc</filename>.";
    };
  };

  config = mkIf cfg.enable {

    environment.etc."yabairc".source = pkgs.writeScript "etc-yabairc" (
      ''
        #!/usr/bin/env sh
        chunkc core::plugin_dir ${toString cfg.plugins.dir}
        chunkc core::hotload ${if cfg.hotload then "1" else "0"}
      ''
        + concatMapStringsSep "\n" (p: "# Config for yabai-${p} plugin\n"+cfg.plugins.${p}.config or "# Nothing to configure") cfg.plugins.list
        + concatMapStringsSep "\n" (p: "chunkc core::load "+p+".so") cfg.plugins.list
        + "\n" + cfg.extraConfig
    );

    launchd.user.agents.yabai = {
      path = [ cfg.package config.environment.systemPath ];
      serviceConfig.ProgramArguments = [ "${getOutput "out" cfg.package}/bin/yabai" ]
        ++ [ "-c" "/etc/yabairc" ];
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
    };

  };
}
