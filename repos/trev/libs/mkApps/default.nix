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
          }:
          {
            inherit script packages inputsFrom;
          }
        )
          value
      else
        {
          script = value;
          packages = [ ];
          inputsFrom = [ ];
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
      inherit (app) script;
    };
  }
)
