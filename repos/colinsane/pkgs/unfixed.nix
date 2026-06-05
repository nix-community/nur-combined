# this is the shared foundation for my standalone package set
# and my nixpkgs overlay.
#
# it uses `callPackage` as a primitive to ensure that:
# - its output attrs could be instantiated in either the toplevel `pkgs` or a dedicated scope.
{
  callPackage,
  lib,
  newScope,
#--- optionals, if you want to support cross compilation ---
  otherSplices ? {
    # populate like this, based on where sane packages is to be instantiated.
    # see generateSplicesForMkScope
    # selfBuildBuild = pkgsBuildBuild.${prefix};
    # selfBuildHost = pkgsBuildHost.${prefix};
    # selfBuildTarget = pkgsBuildTarget.${prefix};
    # selfHostHost = pkgsHostHost.${prefix};
    # selfHostTarget = pkgsHostTarget.${prefix};
    # selfTargetTarget = pkgsTargetTarget.${prefix};
  },
  # `splicePackages`: a helper function; grab the default impl from nixpkgs if not specified.
  splicePackages ? callPackage ({ splicePackages }: splicePackages) {},
  ...
}:
let
  # this machinery is necessary for cross compilation; e.g. `pkgsCross.aarch64-multiplatform.docsets.rust-std`.
  descendSplices = otherSplices: attrName: lib.genAttrs [
    "selfBuildBuild"
    "selfBuildHost"
    "selfBuildTarget"
    "selfHostHost"
    "selfHostTarget"
    "selfTargetTarget"
  ] (platform: (otherSplices."${platform}" or {})."${attrName}" or {});
  # based on lib.filesystem.packagesFromDirectoryRecursive +  makeScopeWithSplicing'.
  callPackagesInTree = {
    callPackage,
    directory,
    newScope,
    otherSplices,
  }:
    lib.concatMapAttrs (
      name: type:
      let
        path = directory + "/${name}";
        default = path + "/package.nix";
      in
      if type == "directory" && builtins.pathExists default then {
        "${name}" = callPackage default { };
      } else if type == "directory" then {
        # recurse into directories
        "${name}" = lib.recurseIntoAttrs (
          lib.makeScopeWithSplicing' {
            inherit newScope splicePackages;
          } {
            otherSplices = descendSplices otherSplices name;
            f = self: callPackagesInTree {
              inherit (self) callPackage newScope;
              inherit otherSplices;
              directory = path;
            };
          }
        );
      } else if type == "regular" && lib.hasSuffix ".nix" name then {
        # call .nix files
        "${lib.removeSuffix ".nix" name}" = callPackage path { };
      } else if type == "regular" then {
        # ignore non-nix files
      } else
        throw "unsupported file type ${type} at path ${path}"
    ) (builtins.readDir directory);
in
callPackagesInTree {
  inherit callPackage newScope otherSplices;
  directory = ./by-name;
} // {
  ## aliases
  inherit (callPackage ({ trivial-builders }: trivial-builders) {})
    copyIntoOwnPackage
    deepLinkIntoOwnPackage
    linkBinIntoOwnPackage
    linkIntoOwnPackage
    rmDbusServices
    rmDbusServicesInPlace
    runCommandLocalOverridable
    runCommandLocalOverridable'
    writeSymlink
    writeSymlinkFile
    ;
  }
