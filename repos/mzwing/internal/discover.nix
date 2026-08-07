# Directory auto-discovery helpers for this repository.
#
# Import as:
#
#   discover = import ./internal/discover.nix { inherit (pkgs) lib; };
#
# Exported functions:
#
#   outputs { dir, args }
#     Recursively find every *.nix file under `dir` (excluding files named
#     default.nix), call each with `args`, and merge the resulting attribute
#     sets. Throws on duplicate top-level attribute names. Used by scripts/.
#
#   subdirs dir
#     Return { <name> = dir + "/<name>"; } for every first-level subdirectory
#     of `dir`. Used by nixos-modules/, darwin-modules/ and home-modules/ so
#     that adding a module directory requires no registration.
#
#   packages { pkgs, dir, sources ? <_sources>, extraArgs ? {} }
#     Automatically wire up packages: for every first-level subdirectory of
#     `dir` containing a default.nix, build it with `pkgs.callPackage` and
#     auto-inject arguments based on the function's formal parameters
#     (builtins.functionArgs), using the following precedence:
#       1. an argument named `source` whose package name exists in `sources`
#          receives sources.<package name>;
#       2. an argument named `pkgs` receives the package set itself (needed
#          by crate2nix-generated Cargo.nix files, which take the whole
#          package set as an argument; without this their default would
#          `import <nixpkgs>`, failing under pure evaluation);
#       3. an argument matching another package in this set receives that
#          package (lazy recursion, e.g. typenix-vscode -> typenix);
#       4. an argument matching a key of `sources` receives that source
#          (e.g. typenix's tree-sitter-nix);
#       5. an argument matching a key of `inject` receives that value
#          (uniform repo-wide injection; by default this provides
#          `buildGoApplication`, the gomod2nix builder from the nvfetcher-
#          pinned gomod2nix source — nixpkgs ships the gomod2nix CLI but
#          not its builder);
#       6. everything else is left for callPackage to resolve from nixpkgs
#          (e.g. sing-box).
#     `inject` maps argument names to values and applies to every package
#     that declares the argument. `extraArgs.<name>` is an explicit
#     exception table that overrides auto-injection for a single package
#     (e.g. typenix-vscode's `source` is sources.typenix).
#     `sources` defaults to the repository's _sources.
#
#     NOTE: rule 3 takes precedence over nixpkgs resolution, so adding a
#     local package whose name collides with a nixpkgs argument used by
#     another package (e.g. a local `sing-box`) shadows it; use `extraArgs`
#     to wire such cases explicitly.
#
#   package { pkgs, name, sources ? <_sources> }
#     Build a single package from ../pkgs/<name> with the same auto-injection
#     rules (lazy: only the requested package is built). Used by modules/ to
#     construct their default packages without duplicating the wiring.
{lib}: let
  # Anchored at this file's location (internal/) so callers don't need to
  # thread the repository root through.
  defaultSources = pkgs: pkgs.callPackage ../_sources/generated.nix {};

  # Repo-wide injected arguments (rule 5 above). `buildGoApplication` is
  # gomod2nix's builder; the gomod2nix source is pinned by nvfetcher and
  # fetched at evaluation time (see gomod2nix.nix for why this is not the
  # nvfetcher FOD), so this works for flake and non-flake consumers alike.
  # The overlay is needed (not a bare callPackage of builder/) because the
  # builder takes the gomod2nix CLI itself as an argument, which nixpkgs
  # no longer provides. Lazy: the overlay is only evaluated when a package
  # actually declares the argument.
  defaultInject = pkgs: let
    overlaid = pkgs.extend (import ((import ./gomod2nix.nix) + "/overlay.nix"));
  in {
    buildGoApplication = overlaid.buildGoApplication;
  };

  # Names of first-level subdirectories of dir that contain a default.nix.
  packageDirs = dir: let
    entries = builtins.readDir dir;
  in
    builtins.filter (
      name:
        entries.${name}
        == "directory"
        && builtins.pathExists (dir + "/${name}/default.nix")
    ) (builtins.attrNames entries);

  packages = {
    pkgs,
    dir,
    sources ? defaultSources pkgs,
    inject ? defaultInject pkgs,
    extraArgs ? {},
  }: let
    autoArgsFor = name: let
      fargs = builtins.functionArgs (import (dir + "/${name}/default.nix"));
      shouldInject = arg:
        (arg == "source" && builtins.hasAttr name sources)
        || arg == "pkgs"
        || builtins.hasAttr arg result
        || builtins.hasAttr arg sources
        || builtins.hasAttr arg inject;
      valueFor = arg:
        if arg == "source" && builtins.hasAttr name sources
        then builtins.getAttr name sources
        else if arg == "pkgs"
        then pkgs
        else if builtins.hasAttr arg result
        then builtins.getAttr arg result
        else if builtins.hasAttr arg sources
        then builtins.getAttr arg sources
        else builtins.getAttr arg inject;
    in
      builtins.listToAttrs (map (arg: {
        name = arg;
        value = valueFor arg;
      }) (builtins.filter shouldInject (builtins.attrNames fargs)));

    result = builtins.listToAttrs (map (name: {
      inherit name;
      value = pkgs.callPackage (dir + "/${name}/default.nix") (
        autoArgsFor name
        // (
          if builtins.hasAttr name extraArgs
          then builtins.getAttr name extraArgs
          else {}
        )
      );
    }) (packageDirs dir));
  in
    result;
in {
  outputs = {
    dir,
    args,
  }: let
    discover = directory: let
      entries = builtins.readDir directory;
    in
      lib.concatMap (
        name: let
          entryType = entries.${name};
          path = directory + "/${name}";
        in
          if entryType == "directory"
          then discover path
          else if entryType == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
          then [path]
          else []
      ) (builtins.attrNames entries);

    merge = accumulated: discovered: let
      duplicateNames = lib.intersectLists (builtins.attrNames accumulated) (builtins.attrNames discovered);
    in
      if duplicateNames != []
      then throw "duplicate discovered output names: ${lib.concatStringsSep ", " duplicateNames}"
      else accumulated // discovered;
  in
    lib.foldl' merge {} (map (path: import path args) (discover dir));

  subdirs = dir: let
    entries = builtins.readDir dir;
  in
    builtins.listToAttrs (map (name: {
      inherit name;
      value = dir + "/${name}";
    }) (builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries)));

  inherit packages;

  package = {
    pkgs,
    name,
    sources ? defaultSources pkgs,
  }:
    builtins.getAttr name (packages {
      inherit pkgs sources;
      dir = ../pkgs;
    });
}
