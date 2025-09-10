{pkgs}: {
  buf = import ./buf {inherit pkgs;};
  go = import ./go {inherit pkgs;};

  mkChecks = builtins.mapAttrs (name: check:
    pkgs.stdenvNoCC.mkDerivation {
      name = name;
      src = check.src or ./.;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      nativeBuildInputs = check.deps or check.nativeBuildInputs or [];

      doCheck = true;
      checkPhase = pkgs.lib.strings.concatLines [
        "export HOME=$(mktemp -d)"
        check.script or check.checkPhase
      ];

      installPhase = ''
        touch $out
      '';
    });
}
