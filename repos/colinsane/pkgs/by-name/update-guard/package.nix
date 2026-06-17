{
  coreutils,
  lib,
  static-nix-shell,
}:
let
  update-guard = static-nix-shell.mkBash {
    pname = "update-guard";
    srcRoot = ./.;
    pkgs = {
      inherit coreutils;
    };
    passthru = {
      days = n: [
        (lib.getExe update-guard)
        (toString n)
      ];
      weekly = update-guard.days 7;
    };
  };
in
  update-guard
