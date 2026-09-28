{
  lib,
  replaceVars,
  stdenvNoCC,
}:

builtins.mapAttrs (
  name: value:
  let
    app =
      if builtins.isAttrs value then
        (
          {
            script,
            packages ? [ ],
            inputsFrom ? [ ],
            description ? script,
          }:
          {
            inherit
              script
              packages
              inputsFrom
              description
              ;
          }
        )
          value
      else
        {
          script = value;
          packages = [ ];
          inputsFrom = [ ];
          description = value;
        };
    pathPackages =
      app.packages
      ++ lib.subtractLists app.inputsFrom (
        lib.flatten (
          map (name: lib.catAttrs name app.inputsFrom) [
            "buildInputs"
            "nativeBuildInputs"
            "propagatedBuildInputs"
            "propagatedNativeBuildInputs"
          ]
        )
      );
    program = stdenvNoCC.mkDerivation (finalAttrs: {
      inherit name;

      app = replaceVars ./app.sh {
        inherit (app) script;
        path = lib.optionalString (pathPackages != [ ]) ''
          export PATH="${lib.makeBinPath pathPackages}:$PATH"
        '';
      };

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;
      doCheck = false;

      installPhase = ''
        install -D ${finalAttrs.app} $out/bin/${name}
      '';
    });
  in
  {
    type = "app";
    program = "${program}/bin/${name}";
    meta = {
      inherit (app) script description;
    };
  }
)
