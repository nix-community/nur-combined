# FIXME: This is one huge pile of mess that hasn't been maintained since, about, early 2024.

{ oldLib }:
let
  diff = {
    maintainers.SomeoneSerge =
      oldLib.maintainers.SomeoneSerge or {
        email = "else+nixpkgs@someonex.net";
        github = "SomeoneSerge";
        githubId = 9720532;
        name = "nobody";
      };

    readByName = import ../read-by-name.nix { lib = oldLib; };

    autocallByName =
      callPackage: baseDirectory:
      let
        files = lib.readByName baseDirectory;
        packages = oldLib.mapAttrs (
          name:
          {
            directory,
            kind,
            path,
          }:
          let
            package = callPackage path { };
          in
          if
            builtins.elem kind [
              "recipe"
              "package"
            ]
          then
            package
          else
            throw "autocallByName: unknown kind ${kind}"
        ) files;
      in
      packages;

    keepMissing = prev: diff: oldLib.filterAttrs (name: _: !(builtins.hasAttr name prev)) diff;
    keepNewer =
      prev: diff:
      oldLib.filterAttrs (
        name: drv:
        !(builtins.hasAttr name prev)
        || !(lib.isDerivation drv)
        || lib.versionAtLeast (lib.getVersion drv) (lib.getVersion prev.${name})
      ) diff;
  };
  lib = oldLib.recursiveUpdate oldLib diff;
in
{
  inherit diff lib;
}
