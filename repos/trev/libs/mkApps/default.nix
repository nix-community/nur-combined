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
            description ? "Run ${name}",
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
          description = "Run ${name}";
        };
    # mkDerivation replaces each input with its `dev` output and marks it
    # with `outputSpecified`, which makes `getBin` return the `dev` output.
    # Clear the mark so `getBin` picks `bin`, or `out` when there is none.
    unspecifyOutput = p: if lib.isDerivation p then p // { outputSpecified = false; } else p;
    pathPackages =
      app.packages
      ++ map unspecifyOutput (
        lib.subtractLists app.inputsFrom (
          lib.flatten (
            map (name: lib.catAttrs name app.inputsFrom) [
              "buildInputs"
              "nativeBuildInputs"
              "propagatedBuildInputs"
              "propagatedNativeBuildInputs"
            ]
          )
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
      inherit (app) description;
    };
  }
)
