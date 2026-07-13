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
          }:
          {
            inherit script packages;
          }
        )
          value
      else
        {
          script = value;
          packages = [ ];
        };
    program = stdenvNoCC.mkDerivation (finalAttrs: {
      inherit name;

      app = replaceVars ./app.sh {
        inherit (app) script;
        path = lib.optionalString (app.packages != [ ]) ''
          export PATH="${lib.makeBinPath app.packages}:$PATH"
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
