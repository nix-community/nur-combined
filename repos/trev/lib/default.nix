{pkgs}: {
  buf = import ./buf {inherit pkgs;};
  go = import ./go {inherit pkgs;};

  mkChecks = builtins.mapAttrs (name: check:
    pkgs.stdenvNoCC.mkDerivation {
      name = name;
      src = check.src or ./.;
      doCheck = true;
      checkPhase = check.checkPhase;
      dontBuild = true;
      nativeBuildInputs = check.nativeBuildInputs or [];
      installPhase = ''
        touch $out
      '';
    }
    // check);
}
