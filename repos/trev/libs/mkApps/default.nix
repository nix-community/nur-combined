{
  lib,
  replaceVars,
  stdenvNoCC,
}:

builtins.mapAttrs (
  name: script:
  let
    app =
      if builtins.isAttrs script then
        (
          {
            text,
            packages ? [ ],
          }:
          {
            inherit text packages;
          }
        )
          script
      else
        {
          text = script;
          packages = [ ];
        };
    program = stdenvNoCC.mkDerivation (finalAttrs: {
      inherit name;

      app = replaceVars ./app.sh {
        script = app.text;
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
      script = app.text;
      description = app.text;
    };
  }
)
