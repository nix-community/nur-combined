/*
  To run:

      nix-shell update.nix --argstr package runmat

  See https://nixos.org/manual/nixpkgs/unstable/#var-passthru-updateScript
*/
{
  package ? null,
  predicate ? null,
  get-script ? pkg: pkg.updateScript or null,
  path ? null,
  max-workers ? null,
  include-overlays ? false,
  keep-going ? false,
  commit ? false,
  skip-prompt ? false,
  order ? null,
}:

let
  system = builtins.currentSystem or "x86_64-linux";
  nixpkgsSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";
  };
  nixpkgs = import nixpkgsSrc { inherit system; config.allowUnfree = true; };
  pkgs = import ./default.nix { pkgs = nixpkgs; };

  inherit (nixpkgs) lib;

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
              updateScript = (get-script package);
              position = package.meta.position or null;
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

  packagesWith = packagesWithPath [ ];

  packagesWithUpdateScriptMatchingPredicate =
    cond: packagesWith (path: pkg: (get-script pkg != null) && cond path pkg);

  packagesWithUpdateScript =
    path: pkgs:
    let
      prefix = lib.splitString "." path;
      pathContent = lib.attrByPath prefix null pkgs;
    in
    if pathContent == null then
      throw "Attribute path `${path}` does not exist."
    else
      packagesWithPath prefix (path: pkg: (get-script pkg != null)) pathContent;

  packageByName =
    path: pkgs:
    let
      package = lib.attrByPath (lib.splitString "." path) null pkgs;
    in
    if package == null then
      throw "Package with an attribute name `${path}` does not exist."
    else if get-script package == null then
      throw "Package with an attribute name `${path}` does not have a `passthru.updateScript` attribute defined."
    else
      {
        attrPath = path;
        inherit package;
      };

  packages =
    if package != null then
      [ (packageByName package pkgs) ]
    else if predicate != null then
      packagesWithUpdateScriptMatchingPredicate predicate pkgs
    else if path != null then
      packagesWithUpdateScript path pkgs
    else
      throw "No arguments provided.\n\n${helpText}";

  helpText = ''
    Please run:

        % nix-shell update.nix --argstr package nautilus

    to run update script for specific package, or

        % nix-shell update.nix --arg predicate '(path: pkg: pkg.updateScript.name or null == "gnome-update-script")'

    to run update script for all packages matching given predicate, or

        % nix-shell update.nix --argstr path gnome

    to run update script for all package under an attribute path.

    You can also add

        --argstr max-workers 8

    to increase the number of jobs in parallel, or

        --arg keep-going true

    to continue running when a single update fails.

    You can also make the updater automatically commit on your behalf from updateScripts
    that support it by adding

        --arg commit true

    To skip the prompt, you can add

        --arg skip-prompt true

    By default, the updater will update the packages in arbitrary order. Alternately, you can force a specific order based on the packages' dependency relations:

        - Reverse topological order (e.g. {"gnome-text-editor", "gimp"}, {"gtk3", "gtk4"}, {"glib"}) is useful when you want checkout each commit one by one to build each package individually but some of the packages to be updated would cause a mass rebuild for the others. Of course, this requires that none of the updated dependents require a new version of the dependency.

            --argstr order reverse-topological

        - Topological order (e.g. {"glib"}, {"gtk3", "gtk4"}, {"gnome-text-editor", "gimp"}) is useful when the updated dependents require a new version of updated dependency.

            --argstr order topological

    Note that sorting requires instantiating each package and then querying Nix store for requisites so it will be pretty slow with large number of packages.
  '';

  packageData =
    { package, attrPath }:
    let
      updateScript = get-script package;
    in
    {
      name = package.name;
      pname = lib.getName package;
      oldVersion = lib.getVersion package;
      updateScript = map toString (lib.toList (updateScript.command or updateScript));
      supportedFeatures = updateScript.supportedFeatures or [ ];
      attrPath = updateScript.attrPath or attrPath;
    };

  packagesJson = nixpkgs.writeText "packages.json" (builtins.toJSON (map packageData packages));

  isTrue = arg: arg == true || arg == "true";

  optionalArgs =
    lib.optional (max-workers != null) "--max-workers=${max-workers}"
    ++ lib.optional (isTrue keep-going) "--keep-going"
    ++ lib.optional (isTrue commit) "--commit"
    ++ lib.optional (isTrue skip-prompt) "--skip-prompt"
    ++ lib.optional (order != null) "--order=${order}";

  args = [ packagesJson ] ++ optionalArgs;

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
    unset shellHook
    exec ${nixpkgs.python3.interpreter} ${nixpkgsSrc}/maintainers/scripts/update.py ${builtins.concatStringsSep " " args}
  '';
  nativeBuildInputs = [
    nixpkgs.git
    nixpkgs.nix
    nixpkgs.cacert
  ];
}
