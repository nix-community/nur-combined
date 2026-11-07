{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  callPackage ? pkgs.callPackage,
  # Legacy NIX_PATH lookups live in this file only.  Flake callers pass
  # explicit values, so their evaluation stays pure.
  nur ? import <nur> {
    inherit pkgs;
    nurpkgs = pkgs;
    repoOverrides = {
      nagy = import ./. { inherit pkgs; };
    };
  },
  dot ? <dot>,
  # Legacy NIX_PATH lookup: `-I local-module=...` sets this argument.
  localModule ?
    if builtins.elem "local-module" (map (x: x.prefix) builtins.nixPath) then <local-module> else null,
  jsonrpc-httpproxy ? builtins.getFlake "github:nagy/jsonrpc-httpproxy",
  # Flake inputs for modules that would otherwise call builtins.getFlake.
  flakes ? { },
}:

let
  packages = lib.packagesFromDirectoryRecursive {
    directory = ./pkgs/by-name;
    callPackage = callPackage;
  };
in
packages
// {
  # Needs private inputs, so this file does not live in ./pkgs/by-name.
  my-build-env = callPackage ./pkgs/my-build-env.nix {
    inherit
      nur
      dot
      localModule
      jsonrpc-httpproxy
      flakes
      ;
  };

  # Extras
  lib = lib.foldr lib.mergeAttrs { } (
    map (x: import x { inherit pkgs; })
      # fileset
      (lib.filesystem.listFilesRecursive ./lib)
  );

  modules = lib.listToAttrs (
    map (x: {
      name = lib.removeSuffix ".nix" (baseNameOf x);
      value = x;
    }) (lib.filesystem.listFilesRecursive ./modules)
  );

  qemuImages = lib.recurseIntoAttrs (callPackage ./pkgs/qemu-images { });

  python3Packages = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      directory = ./pkgs/python3-packages;
      callPackage = pkgs.python3Packages.callPackage;
      newScope = pkgs.python3Packages.newScope;
    }
  );

  emacsPackages = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      directory = ./pkgs/emacs-packages;
      callPackage = pkgs.emacs.pkgs.callPackage;
    }
  );

  systemBuilder = import <nixpkgs/nixos/lib/eval-config.nix> {
    specialArgs = { inherit nur; };
    modules = [ <nixos-config> ];
  };

  systemBuilderLiveCD = import <nixpkgs/nixos/lib/eval-config.nix> {
    specialArgs = { inherit nur; };
    modules = [
      (
        { modulesPath, ... }:
        {
          imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-base.nix" ];
          isoImage.squashfsCompression = "zstd -Xcompression-level 3";
        }
      )
      <nixos-config>
    ];
  };

}
