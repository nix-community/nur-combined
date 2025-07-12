{pkgs}: {
  mkChecks = builtins.mapAttrs (name: check:
    pkgs.stdenvNoCC.mkDerivation {
      name = name;
      src = ./.;
      doCheck = true;
      dontBuild = true;
      installPhase = ''
        touch $out
      '';
    }
    // check);
}
