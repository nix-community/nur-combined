{ buildEnv, writeShellScriptBin, writeTextDir, writeText, system }:

{ name ? "user-environment"

, # A list of packages to install
  packages

, # If true, don't allow the user-environment to be modified imperatively
  static ? false
}:

let
  # https://github.com/NixOS/nix/blob/387f824cab50682e373ade49dcec4e6f99c10a42/src/nix-env/user-env.cc#L47
  # We're forced to take a detour through `_outPath` due to
  # `builtins.toJSON`'s behavior when used with any set that contains
  # an `outPath` attribute (it just prints the value of `outPath`)
  manifest-json = writeText "user-environment.json" (builtins.toJSON (map
    (pkg:
      let
        cleanedOutputs =
          let
            cleanOutputDrv = drv: {
              _outPath = drv.outPath;
            };
            outputNVList = map
              (output: {
                name = output;
                value = cleanOutputDrv pkg."${output}";
              }) pkg.outputs;
          in builtins.listToAttrs outputNVList;
      in {
        type = "derivation";
        inherit (pkg) name meta outputs;
        inherit system;
        _outPath = pkg.outPath;
      } // cleanedOutputs) packages));
  manifest = writeText "manifest.nix"
    (if static
     then ''
       abort "user-environment is static and cannot be modified imperatively"
     ''
     else ''
       map (spec:
         let
           strippedSpec =
             builtins.removeAttrs spec (spec.outputs ++ ["_outPath"]);
           restoredOutputs =
             let
               restoreOutputDrv = drvSpec: {
                 outPath = drvSpec._outPath;
               };
               outputNVList = map
                 (output: {
                   name = output;
                   value = restoreOutputDrv spec."''${output}";
                 }) spec.outputs;
             in builtins.listToAttrs outputNVList;
         in strippedSpec // {
           outPath = spec._outPath;
         } // restoredOutputs
       ) (builtins.fromJSON (builtins.readFile "${manifest-json}"))
     '');

  profile = derivation {
    inherit name manifest;
    system = "builtin";
    builder = "builtin:buildenv";

    # https://github.com/NixOS/nix/blob/387f824cab50682e373ade49dcec4e6f99c10a42/src/nix-env/buildenv.nix#L10
    derivations =
      map (d:
        [ (d.meta.active or "true")
          (d.meta.priority or 5)
          (builtins.length d.outputs)
        ] ++ map (output: builtins.getAttr output d) d.outputs)
        packages;

    preferLocalBuild = true;
    allowSubstitutes = false;
  };
in writeShellScriptBin "install-user-environment" ''
  nix-env --set ${profile}
''
