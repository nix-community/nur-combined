{ ... }: let
  # https://github.com/NixOS/nixpkgs/commit/62a6eeb1f3da0a5954ad2da54c454eb7fc1c6e5d
  # convert { nixpkgs = ./path; } attrsets to [ { path = ./path; prefix = "nixpkgs" } ] format
  nixPathList = nixPathAttrs: let 
    nixPath = {
      # never really makes sense to omit <nix>?
      nix = <nix>;
    } // nixPathAttrs;
  in builtins.map (prefix: {
    inherit prefix;
    path = toString nixPath.${prefix};
  }) (builtins.attrNames nixPath);

  # import a file with a new nixPath
  nixPathImport = nixPath: nixPathScopedImport nixPath { };

  # import a file with a new nixPath and scope
  nixPathScopedImport = nixPath': newScope: let
    nixPath = if builtins.isAttrs nixPath' then nixPathList nixPath' else nixPath';
    import = builtins.scopedImport scope;
    scopedImport = newScope: builtins.scopedImport (scope // newScope);
    scope = newScope // {
      inherit import scopedImport;
      __nixPath = nixPath;
      builtins = builtins // (newScope.builtins or { }) // {
        inherit nixPath import scopedImport;
      };
    };
  in import;
in {
  inherit nixPathImport nixPathScopedImport nixPathList;
}
