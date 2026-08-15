{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.opencodex = {
    enable = mkEnableOption (
      lib.mdDoc "Universal provider proxy for OpenAI Codex & Claude Code (opencodex)"
    );

    package = mkPackageOption pkgs "opencodex" { };

    stateDir = mkOption {
      type = with types; nullOr path;
      default = null;
      description = lib.mdDoc ''
        Directory opencodex uses for its config and app data (`OPENCODEX_HOME`).
        When `null`, a platform default is used: the XDG data dir
        (`${config.xdg.dataHome}/opencodex`) under home-manager, or
        `/var/lib/opencodex` for the NixOS system service.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 10100;
      description = lib.mdDoc ''
        Port the proxy and web dashboard listen on. Pinned via `ocx start --port`
        so the service is deterministic and does not auto-pick/persist a port.
      '';
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      description = lib.mdDoc ''
        File in the format of an EnvironmentFile as described by systemd.exec(5).
        Use this to provide `OPENCODEX_API_AUTH_TOKEN` / `OPENCODEX_ADMIN_AUTH_TOKEN`
        and other secrets without embedding them in the nix store. Only required
        when binding a non-loopback hostname in the opencodex dashboard.
      '';
    };

    extraEnvironment = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = lib.mdDoc "Extra environment variables passed to the service.";
    };
  };
}
