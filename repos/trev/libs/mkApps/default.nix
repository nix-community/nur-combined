{
  replaceVars,
  writeShellScriptBin,
}:

builtins.mapAttrs (
  name: script:
  let
    program = writeShellScriptBin name (
      replaceVars ./app.sh {
        inherit script;
      }
    );
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
