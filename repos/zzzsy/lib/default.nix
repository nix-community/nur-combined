{
  inputs,
  lib,
  ...
}:
rec {

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  infuse = (import inputs.infuse.outPath { inherit lib; }).v1.infuse;

  overlayScope = {
    inherit
      inputs
      lib
      infuse
      ;
  };

  callOverlay =
    overlay:
    let
      args = builtins.functionArgs overlay;

      missingRequired =
        args
        |> lib.filterAttrs (name: hasDefault: !hasDefault && !(builtins.hasAttr name overlayScope))
        |> builtins.attrNames;
    in
    if args == { } then
      overlay
    else if missingRequired != [ ] then
      throw "callOverlay: missing required args: ${lib.concatStringsSep ", " missingRequired}"
    else
      overlay (lib.intersectAttrs args overlayScope);
  importNixDir =
    {
      dir,
      valueFn,
      nameFn ? name: lib.removeSuffix ".nix" name,
      exclude ? [ "default.nix" ],
    }:
    dir
    |> (dir: if builtins.pathExists dir then builtins.readDir dir else { })
    |> lib.filterAttrs (
      name: type: type == "regular" && lib.hasSuffix ".nix" name && !(builtins.elem name exclude)
    )
    |> lib.mapAttrs' (
      name: type:
      let
        baseName = lib.removeSuffix ".nix" name;
        path = dir + "/${name}";
      in
      lib.nameValuePair (nameFn name) (valueFn {
        inherit
          name
          baseName
          path
          type
          ;
      })
    );

  importOverlays =
    dir:
    importNixDir {
      inherit dir;
      exclude = [ ];
      valueFn = { path, ... }: import path |> callOverlay;
    };

  importModules =
    dir:
    importNixDir {
      inherit dir;
      valueFn = { path, ... }: import path;
    };

  importPackages =
    pkgs: sources: dir:
    lib.packagesFromDirectoryRecursive {
      callPackage =
        file: args:
        let
          sourceName =
            file
            |> toString
            |> lib.removeSuffix "/package.nix"
            |> lib.removeSuffix ".nix"
            |> baseNameOf
            |> builtins.unsafeDiscardStringContext;
        in
        lib.callPackageWith (
          pkgs
          // {
            source = sources.${sourceName} or (throw "No nvfetcher source found for package '${sourceName}'");
          }
        ) file args;

      directory = builtins.path {
        path = dir;
        filter = path: type: !(type == "directory" && baseNameOf path == "_sources");
      };
    };

  flattenPkgs =
    sep: pkgs:
    pkgs
    |> lib.attrsets.mapAttrsToListRecursiveCond (_path: value: !(lib.isDerivation value)) (
      path: value:
      lib.optional (lib.isDerivation value) (lib.nameValuePair (lib.concatStringsSep sep path) value)
    )
    |> lib.flatten
    |> builtins.listToAttrs;
}
