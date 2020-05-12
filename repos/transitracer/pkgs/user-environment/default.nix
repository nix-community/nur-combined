{ buildEnv, writeShellScriptBin, writeTextDir, linkFarm, manifestBuilder }:

{ name ? "user-environment"

, # A list of packages to install
  packages

, # If true, don't allow the user-environment to be modified imperatively
  static ? false
}:

let
  manifest =
    if static
    then writeTextDir "manifest.nix" ''
      abort "user-environment is static and cannot be modified imperatively"
    ''
    else linkFarm "manifest.nix" [{
      name = "manifest.nix";
      path = manifestBuilder packages;
    }];

  profile = buildEnv {
    inherit name;
    
    paths = packages ++ [ manifest ];
  };
in writeShellScriptBin "install-user-environment" ''
  nix-env --set ${profile}
''
