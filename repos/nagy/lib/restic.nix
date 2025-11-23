{
  pkgs,
  lib ? pkgs.lib,
}:

{
  mkResticWrapper =
    {
      name,
      repo,
      shortcut ? null,
      runtimeEnv ? { },
      fromRepo ? "",
    }:
    pkgs.writeShellApplication {
      name = "restic-${name}";
      runtimeInputs = [ pkgs.restic ];
      runtimeEnv = {
        RESTIC_READ_CONCURRENCY = 1;
        RESTIC_REPOSITORY = repo;
        RESTIC_CACHE_DIR = "/tmp/restic-cache-${name}";
        RESTIC_FROM_REPOSITORY = fromRepo;
      } // runtimeEnv;
      derivationArgs.passthru = {
        inherit repo;
        shortcommands = lib.optionalAttrs (shortcut != null) {
          "📀${shortcut}" = [ "restic-${name}" ];
          "📀${shortcut}b" = [
            "restic-${name}"
            "backup"
          ];
          "📀${shortcut}s" = [
            "restic-${name}"
            "snapshots"
            "--no-lock"
          ];
          "📀${shortcut}sj" = [
            "restic-${name}"
            "snapshots"
            "--json"
            "--no-lock"
          ];
        };
      };
      text = ''
        exec restic "$@"
      '';
    };
}
