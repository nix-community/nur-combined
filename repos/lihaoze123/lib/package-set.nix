{ pkgs, packageRoot ? ../pkgs }:

let
  inherit (pkgs) lib;
  directories = lib.filterAttrs
    (name: type: type == "directory" && builtins.pathExists (packageRoot + "/${name}/default.nix"))
    (builtins.readDir packageRoot);
  scope = lib.makeScope pkgs.newScope (self: lib.mapAttrs
    (name: _:
      let
        directory = packageRoot + "/${name}";
        package = self.callPackage (directory + "/default.nix") { };
        updateInfo =
          if builtins.pathExists (directory + "/update.json")
          then builtins.fromJSON (builtins.readFile (directory + "/update.json"))
          else { kind = "package"; attr = name; };
        updateScript = pkgs.writeShellApplication {
          name = "update-${name}";
          runtimeInputs = with pkgs; [ python3 nix-update nixpkgs-fmt nodejs prefetch-npm-deps ];
          text = ''
            exec python3 ${../scripts/update-package.py} ${lib.escapeShellArg (updateInfo.group or name)}
          '';
        };
      in
      package // {
        # Maintenance attributes preserve the original derivation and cache path.
        inherit updateInfo updateScript;
        passthru = (package.passthru or { }) // { inherit updateInfo updateScript; };
      })
    directories);
in
lib.getAttrs (builtins.attrNames directories) scope
