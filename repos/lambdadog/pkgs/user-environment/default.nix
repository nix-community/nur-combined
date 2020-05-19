{ buildEnv, writeShellScriptBin, writeTextDir, writeText }:

{ name ? "user-environment"

, # A list of packages to install
  packages

, # If true, don't allow the user-environment to be modified imperatively
  static ? false
}:

let
  manifest-json = writeText "user-environment.json" (builtins.toJSON (map
    (pkg: {
      inherit (pkg) name type;
      _outPath = pkg.outPath;
    }) packages));
  manifest-nix = writeTextDir "manifest.nix"
    (if static
     then ''
       abort "user-environment is static and cannot be modified imperatively"
     ''
     else ''
       map (spec: {
         inherit (spec) name type;
         outPath = spec._outPath;
         out = {
           outPath = spec._outPath;
         };
       }) (builtins.fromJSON (builtins.readFile "${manifest-json}"))
     '');

  profile = buildEnv {
    inherit name;
    
    paths = packages ++ [ manifest-nix ];
  };
in writeShellScriptBin "install-user-environment" ''
  nix-env --set ${profile}
''
