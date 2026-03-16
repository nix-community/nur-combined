{
  lib,
  runtimeShell,
  stdenvNoCC,
}:
builtins.mapAttrs (
  name: app:
  let
    program = stdenvNoCC.mkDerivation (finalAttrs: {
      name = name;

      runtimeInputs = app.deps or app.runtimeInputs or [ ];

      dontUnpack = true;

      configurePhase = ''
        echo "#!${runtimeShell}" >> ${name}
        echo 'export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' >> ${name}
        echo "${app.script}" >> ${name}

        chmod +x ${name}
      '';

      dontBuild = true;
      doCheck = false;

      installPhase = ''
        mkdir -p $out/bin
        cp ${name} $out/bin/${name}
      '';

      dontFixup = true;
    });
  in
  {
    type = "app";
    program = "${program}/bin/${name}";
    meta.description = app.description or app.meta.description or name;
  }
)
