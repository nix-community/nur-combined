{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;

  callPackage = pkgs.lib.callPackageWith (pkgs // { nur.repos.josh = pkgs' // internalPkgs; });

  internalPkgs = {
    checkKubeImages = args: callPackage ./internal/check-kube-images.nix args;
    fetchhelm = callPackage ./internal/fetchhelm.nix { };
    nix-prefetch-helm = callPackage ./internal/nix-prefetch-helm.nix { };
    nixhelm-update = callPackage ./internal/nixhelm-update.nix { };
    renderHelmTemplate = args: callPackage ./internal/helm-render-template.nix args;
  };

  packagesFromDirectory =
    directory:
    lib.attrsets.concatMapAttrs (
      name: type:
      let
        filename = lib.path.append directory name;
        isNix = lib.strings.hasSuffix ".nix" name;
        basename = lib.strings.removeSuffix ".nix" name;
      in
      if type == "regular" && isNix then { "${basename}" = callPackage filename { }; } else { }
    ) (builtins.readDir directory);

  pkgs' = lib.attrsets.concatMapAttrs (
    name: type:
    let
      dirname = lib.path.append ./pkgs name;
    in
    if type == "directory" then packagesFromDirectory dirname else { }
  ) (builtins.readDir ./pkgs);
in
pkgs'
