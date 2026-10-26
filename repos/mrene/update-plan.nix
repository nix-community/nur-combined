# Computes what ./update-all.sh should do for each package, as a list of
#   { attr; args = [ nix-update flags ]; parent = attr or null; } or { attr; skip = reason; }
# Vendored dependencies exposed through `passthru` (e.g. narwal-ha.bbpb) come
# right before the package that uses them, with `parent` set.
# `attrs` is a space-separated list of attribute paths; empty means everything.
{
  attrs ? "",
}:

let
  root = toString ./.;
  flake = builtins.getFlake root;
  pkgs = import flake.inputs.nixpkgs {
    system = builtins.currentSystem;
    config.allowUnfree = true;
  };
  inherit (pkgs) lib;
  requested =
    if attrs == "" then
      import ./list-packages.nix { inherit pkgs; }
    else
      lib.filter (a: a != "") (lib.splitString " " attrs);

  nur = import ./default.nix { inherit pkgs; };

  # Path relative to the repo, or null for paths outside it (e.g. nixpkgs).
  relative =
    path:
    if lib.isString path && lib.hasPrefix (root + "/") path then
      lib.removePrefix (root + "/") path
    else
      null;

  # File defining the package, relative to the repo.
  fileOf =
    p:
    let
      position = (builtins.tryEval (p.meta.position or "")).value;
    in
    if lib.isString position then relative (builtins.head (lib.splitString ":" position)) else null;

  hasSrc = p: p ? src && (p.src ? url || p.src ? urls);

  isNixUpdate =
    s: builtins.isList s && s != [ ] && lib.hasSuffix "/bin/nix-update" (toString (builtins.head s));

  # Builders like buildHomeAssistantComponent set version themselves, so point
  # nix-update at the file defining the package unless it says otherwise.
  withFile =
    file: args:
    if lib.any (lib.hasPrefix "--override-filename") args then
      args
    else
      args ++ [ "--override-filename=${file}" ];

  entry =
    parent: attr: p:
    let
      file = fileOf p;
    in
    {
      inherit attr parent;
      # yarn-berry packages: nix-update can't regenerate this, the script does.
      missingHashes = if p ? missingHashes then relative (toString p.missingHashes) else null;
    }
    // (
      if file == null then
        { skip = "defined outside this repo"; }
      else if !hasSrc p then
        { skip = "no fetchable src"; }
      else if !(p ? updateScript) then
        { args = withFile file [ ]; }
      else if p.updateScript == null then
        { skip = "updateScript = null"; }
      else if isNixUpdate p.updateScript then
        { args = withFile file (map toString (builtins.tail p.updateScript)); }
      else
        { skip = "custom updateScript is not supported"; }
    );

  vendoredDeps =
    attr: p:
    lib.concatLists (
      lib.mapAttrsToList (
        name: dep:
        let
          isDrv = builtins.tryEval (lib.isDerivation dep);
        in
        lib.optional (name != "tests" && isDrv.success && isDrv.value && fileOf dep != null && hasSrc dep) (
          entry attr "${attr}.${name}" dep
        )
      ) (p.passthru or { })
    );

  plan =
    attr:
    let
      p = lib.getAttrFromPath (lib.splitString "." attr) nur;
    in
    vendoredDeps attr p ++ [ (entry null attr p) ];
in
lib.concatMap plan requested
