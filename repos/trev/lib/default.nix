{pkgs}: {
  mkChecks = builtins.mapAttrs (name: check:
    pkgs.stdenvNoCC.mkDerivation {
      name = name;
      src = ./.;
      nativeBuildInputs = check.packages;
      doCheck = true;
      checkPhase = check.script;
      dontBuild = true;
      installPhase = ''
        touch $out
      '';
    });
}
