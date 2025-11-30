{ pkgs }:
builtins.mapAttrs (
  name: app:
  let
    program = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      name = name;

      runtimeInputs = app.deps or app.runtimeInputs or [ ];

      dontUnpack = true;

      configurePhase = ''
        echo "#!${pkgs.runtimeShell}" >> ${name}
        echo 'export PATH="${pkgs.lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' >> ${name}
        echo "${app.script}" >> ${name}

        chmod +x ${name}
      '';

      dontBuild = true;
      doCheck = false;

      installPhase = ''
        mkdir -p $out/bin
        cp ${name} $out/bin/${name}
      '';
    });
  in
  {
    type = "app";
    program = "${program}/bin/${name}";
    meta.description = app.description or app.meta.description or name;
  }
)
