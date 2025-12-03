{ lib, pkgs, ... }:
{
  script =
    name: content:
    pkgs.writers.makeScriptWriter
      {
        interpreter = lib.getExe pkgs.bashInteractive;
        check = lib.escapeShellArgs [
          (lib.getExe pkgs.shellcheck)
          "--norc"
          "--severity=info"
          "--exclude=SC2016"
          pkgs.shellvaculib.file
        ];
      }
      "/bin/${name}"
      ''
        source ${lib.escapeShellArg pkgs.shellvaculib.file}
        ${content}
      '';
}
