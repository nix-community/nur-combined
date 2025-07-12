{pkgs}: {
  mkChecks = builtins.mapAttrs (name: check:
    pkgs.runCommandLocal name {
      nativeBuildInputs = check.packages;
    } ''
      cd ${./.}
      HOME=$PWD
      ${check.script}
      touch $out
    '');
}
