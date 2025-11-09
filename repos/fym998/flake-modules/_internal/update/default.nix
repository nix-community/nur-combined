{ lib, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, config, ... }:
    {
      options.update = {
        packages = mkOption {
          type = types.lazyAttrsOf types.package;
          default = null;
          description = "List of packages to run update scripts for.";
        };

        getScript = mkOption {
          type = types.functionTo (types.nullOr (types.either types.str (types.listOf types.str)));
          default = pkg: pkg.updateScript or null;
          defaultText = lib.literalExpression "pkg: pkg.updateScript or null";
          description = ''
            Function that takes a package and returns its update script or null.
            By default, it returns `pkg.updateScript` if it exists.
          '';
        };

        predicate = mkOption {
          type = types.functionTo (types.functionTo types.bool);
          default = _path: _pkg: true;
          defaultText = lib.literalExpression "_path: _pkg: true";
          description = ''
            Optional predicate function to filter packages to update.
            The function takes two arguments: attribute path (string) and package (derivation),
            and should return true for packages that should be updated.
          '';
        };

        nixpkgsPath = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            NIX_PATH entry for nixpkgs to be used by the update script.
            If null, the system's nixpkgs will be used.
          '';
        };
      };

      config.legacyPackages._update =
        let
          cfg = config.update;

          # Remove duplicate elements from the list based on some extracted value. O(n^2) complexity.
          nubOn =
            f: list:
            if list == [ ] then
              [ ]
            else
              let
                x = lib.head list;
                xs = lib.filter (p: f x != f p) (lib.drop 1 list);
              in
              [ x ] ++ nubOn f xs;

          /*
            Recursively find all packages (derivations) in `pkgs` matching `cond` predicate.

            Type: packagesWithPath :: AttrPath → (AttrPath → derivation → bool) → AttrSet → List<AttrSet{attrPath :: str; package :: derivation; }>
                  AttrPath :: [str]

            The packages will be returned as a list of named pairs comprising of:
              - attrPath: stringified attribute path (based on `rootPath`)
              - package: corresponding derivation
          */
          packagesWithPath =
            rootPath: cond: pkgs:
            let
              packagesWithPathInner =
                path: pathContent:
                let
                  result = builtins.tryEval pathContent;

                  somewhatUniqueRepresentant =
                    { package, attrPath }:
                    {
                      updateScript = cfg.getScript package;
                      # Some updaters use the same `updateScript` value for all packages.
                      # Also compare `meta.description`.
                      position = package.meta.position or null;
                      # We cannot always use `meta.position` since it might not be available
                      # or it might be shared among multiple packages.
                    };

                  dedupResults = lst: nubOn somewhatUniqueRepresentant (lib.concatLists lst);
                in
                if result.success then
                  let
                    evaluatedPathContent = result.value;
                  in
                  if lib.isDerivation evaluatedPathContent then
                    lib.optional (cond path evaluatedPathContent) {
                      attrPath = lib.concatStringsSep "." path;
                      package = evaluatedPathContent;
                    }
                  else if lib.isAttrs evaluatedPathContent then
                    # If user explicitly points to an attrSet or it is marked for recursion, we recur.
                    if
                      path == rootPath
                      || evaluatedPathContent.recurseForDerivations or false
                      || evaluatedPathContent.recurseForRelease or false
                    then
                      dedupResults (
                        lib.mapAttrsToList (name: elem: packagesWithPathInner (path ++ [ name ]) elem) evaluatedPathContent
                      )
                    else
                      [ ]
                  else
                    [ ]
                else
                  [ ];
            in
            packagesWithPathInner rootPath pkgs;

          # Recursively find all packages (derivations) in `pkgs` matching `cond` predicate.
          packagesWith = packagesWithPath [ ];

          # Recursively find all packages in `pkgs` with updateScript matching given predicate.
          packagesWithUpdateScriptMatchingPredicate =
            cond: packagesWith (path: pkg: (cfg.getScript pkg != null) && cond path pkg);

          # Transform a matched package into an object for update.py.
          packageData =
            { package, attrPath }:
            let
              updateScript = cfg.getScript package;
            in
            {
              inherit (package) name;
              pname = lib.getName package;
              oldVersion = lib.getVersion package;
              updateScript = map toString (lib.toList (updateScript.command or updateScript));
              supportedFeatures = updateScript.supportedFeatures or [ ];
              attrPath = updateScript.attrPath or attrPath;
            };

          # JSON file with data for update.py.
          packagesJson = pkgs.writeText "packages.json" (
            builtins.toJSON (
              map packageData (packagesWithUpdateScriptMatchingPredicate cfg.predicate cfg.packages)
            )
          );
        in
        pkgs.writeShellApplication {
          name = "update";
          runtimeEnv =
            if cfg.nixpkgsPath == null then
              { }
            else
              {
                NIX_PATH = "nixpkgs=${cfg.nixpkgsPath}";
              };
          runtimeInputs = [
            pkgs.python3
            pkgs.git
            pkgs.nix
            pkgs.cacert
          ];
          text = ''
            python3 ${./update.py} ${packagesJson} "$@"
          '';
          meta = {
            inherit (pkgs.python3.meta) platforms;
          };
        };
    }
  );
}
