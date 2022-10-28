{
  package ? null,
  maintainer ? null,
  predicate ? null,
  path ? null,
  max-workers ? null,
  include-overlays ? false,
  keep-going ? null,
  commit ? null,
}:
# TODO: add assert statements
let
  nixpkgs = import <nixpkgs> (
    if !include-overlays
    then {overlays = [];}
    else if include-overlays
    then {} # Let Nixpkgs include overlays impurely.
    else {overlays = include-overlays;}
  );
  pkgs = import ../default.nix {pkgs = nixpkgs;};

  inherit (nixpkgs) lib;

  /*
  Remove duplicate elements from the list based on some extracted value. O(n^2) complexity.
  */
  nubOn = f: list:
    if list == []
    then []
    else let
      x = lib.head list;
      xs = lib.filter (p: f x != f p) (lib.drop 1 list);
    in
      [x] ++ nubOn f xs;

  /*
   Recursively find all packages (derivations) in `pkgs` matching `cond` predicate.

  Type: packagesWithPath :: AttrPath → (AttrPath → derivation → bool) → AttrSet → List<AttrSet{attrPath :: str; package :: derivation; }>
        AttrPath :: [str]

  The packages will be returned as a list of named pairs comprising of:
    - attrPath: stringified attribute path (based on `rootPath`)
    - package: corresponding derivation
  */
  packagesWithPath = rootPath: cond: pkgs: let
    packagesWithPathInner = path: pathContent: let
      result = builtins.tryEval pathContent;

      dedupResults = lst:
        nubOn ({
          package,
          attrPath,
        }:
          package.updateScript) (lib.concatLists lst);
    in
      if result.success
      then let
        evaluatedPathContent = result.value;
      in
        if lib.isDerivation evaluatedPathContent
        then
          lib.optional (cond path evaluatedPathContent) {
            attrPath = lib.concatStringsSep "." path;
            package = evaluatedPathContent;
          }
        else if lib.isAttrs evaluatedPathContent
        then
          # If user explicitly points to an attrSet or it is marked for recursion, we recur.
          if path == rootPath || evaluatedPathContent.recurseForDerivations or false || evaluatedPathContent.recurseForRelease or false
          then dedupResults (lib.mapAttrsToList (name: packagesWithPathInner (path ++ [name])) evaluatedPathContent)
          else []
        else []
      else [];
  in
    packagesWithPathInner rootPath pkgs;

  /*
  Recursively find all packages (derivations) in `pkgs` matching `cond` predicate.
  */
  packagesWith = packagesWithPath [];

  allPackagesWithUpdateScript = packagesWith (_: builtins.hasAttr "updateScript");

  /*
  Recursively find all packages under `path` in `pkgs` with updateScript.
  */
  packagesWithUpdateScript = path: pkgs: let
    prefix = lib.splitString "." path;
    pathContent = lib.attrByPath prefix null pkgs;
  in
    if pathContent == null
    then builtins.throw "Attribute path `${path}` does not exist."
    else
      packagesWithPath prefix (path: builtins.hasAttr "updateScript")
      pathContent;

  /*
  List of packages matched based on the CLI arguments.
  */
  packages =
    if path != null
    then packagesWithUpdateScript path pkgs
    else allPackagesWithUpdateScript pkgs;

  helpText = ''
    Please run:

        % nix-shell maintainers/scripts/update.nix --argstr maintainer garbas

    to run all update scripts for all packages that lists \`garbas\` as a maintainer
    and have \`updateScript\` defined, or:

        % nix-shell maintainers/scripts/update.nix --argstr package gnome.nautilus

    to run update script for specific package, or

        % nix-shell maintainers/scripts/update.nix --arg predicate '(path: pkg: pkg.updateScript.name or null == "gnome-update-script")'

    to run update script for all packages matching given predicate, or

        % nix-shell maintainers/scripts/update.nix --argstr path gnome

    to run update script for all package under an attribute path.

    You can also add

        --argstr max-workers 8

    to increase the number of jobs in parallel, or

        --argstr keep-going true

    to continue running when a single update fails.

    You can also make the updater automatically commit on your behalf from updateScripts
    that support it by adding

        --argstr commit true
  '';

  /*
  Transform a matched package into an object for update.py.
  */
  packageData = {
    package,
    attrPath,
  }: {
    inherit (package) name;
    pname = lib.getName package;
    oldVersion = lib.getVersion package;
    updateScript = map builtins.toString (lib.toList (package.updateScript.command or package.updateScript));
    supportedFeatures = package.updateScript.supportedFeatures or [];
    attrPath = package.updateScript.attrPath or attrPath;
  };

  /*
  JSON file with data for update.py.
  */
  packagesJson = nixpkgs.writeText "packages.json" (builtins.toJSON (map packageData packages));

  optionalArgs =
    lib.optional (max-workers != null) "--max-workers=${max-workers}"
    ++ lib.optional (keep-going == "true") "--keep-going"
    ++ lib.optional (commit == "true") "--commit";

  args = [packagesJson] ++ optionalArgs;
in
  nixpkgs.stdenv.mkDerivation {
    name = "nixpkgs-update-script";
    buildCommand = ''
      echo ""
      echo "----------------------------------------------------------------"
      echo ""
      echo "Not possible to update packages using \`nix-build\`"
      echo ""
      echo "${helpText}"
      echo "----------------------------------------------------------------"
      exit 1
    '';
    shellHook = ''
      unset shellHook # do not contaminate nested shells
      exec ${nixpkgs.python3.interpreter} ${./update.py} ${builtins.concatStringsSep " " args}
    '';
  }
