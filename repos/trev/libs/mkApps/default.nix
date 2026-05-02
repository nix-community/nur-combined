{
  stdenvNoCC,
  replaceVars,
}:

builtins.mapAttrs (
  name: script:
  let
    program = stdenvNoCC.mkDerivation (finalAttrs: {
      inherit name;

      app = replaceVars ./app.sh {
        inherit script;
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
      inherit script;
      description = script;
    };
  }
)
