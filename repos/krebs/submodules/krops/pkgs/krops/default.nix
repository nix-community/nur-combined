let
  lib = import ../../lib;
in

{ exec, nix, openssh, populate, writeDash }: rec {

  rebuild = target:
    exec "rebuild.${target.host}" rec {
      filename = "${openssh}/bin/ssh";
      argv = [
        filename
        "-l" target.user
        "-p" target.port
        target.host
        "nixos-rebuild switch -I ${lib.escapeShellArg target.path}"
      ];
    };

  writeDeploy = name: { force ? false, source, target }: let
    target' = lib.mkTarget target;
  in
    writeDash name ''
      set -efu
      ${populate { inherit force source; target = target'; }}
      ${rebuild target'}
    '';

  writeTest = name: { force ? false, source, target }: let
    target' = lib.mkTarget target;
  in
    assert lib.isLocalTarget target';
    writeDash name ''
      set -efu
      ${populate { inherit force source; target = target'; }}
      ${nix}/bin/nix-build \
          -A system \
          -I ${target'.path} \
          --keep-going \
          --no-out-link \
          --show-trace \
          '<nixpkgs/nixos>'
    '';

}
