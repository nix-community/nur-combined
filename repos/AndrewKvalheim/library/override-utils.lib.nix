{ library ? ./., nur ? null, search ? [ ], stable }:

let
  inherit (builtins) attrNames attrValues filter findFile functionArgs isAttrs isPath length mapAttrs nixPath pathExists removeAttrs tryEval;
  inherit (stable) fetchgit makeWrapper symlinkJoin;
  inherit (stable.lib) attrByPath concatMapStringsSep concatStringsSep const defaultTo escapeShellArg findFirst genAttrs getAttrFromPath hasAttrByPath imap1 info last mapAttrs' mapAttrsToList nameValuePair naturalSort optional optionals optionalAttrs optionalString partition recurseIntoAttrs recursiveUpdate showAttrPath throwIf toList;
  inherit (import ./utilities.lib.nix { inherit (stable) lib; }) uniqueBy versionSatisfied;

  # Utilities
  composeOverrides = f1: f2: a0: let o1 = f1 a0; o2 = f2 (a0 // o1); in o1 // o2;
  ignoreLicense = p: (p.overrideAttrs (a: recursiveUpdate a { meta.license = [ ]; }));
  isEmpty = v: length (if isAttrs v then attrNames v else v) == 0;
  isFunctor = repo: path: (tryEval (hasAttrByPath (path ++ [ "__functor" ]) repo)).value;
  isLocal = r: isPath r || r._local or false;
  isPythonPackages = s: s ? pythonAtLeast;
  isScope = repo: path: (tryEval (hasAttrByPath (path ++ [ "overrideScope" ]) repo)).value;
  isSet = repo: path: (tryEval (attrByPath (path ++ [ "recurseForDerivations" ]) false repo)).value;
  mkRepo = name: path: (import path { inherit (stable) config; overlays = [ ]; }) // { _name = name; };
  repoEq = a: b: repoName a == repoName b;
  repoName = r: if isPath r then toString r else r._name or r.lib.trivial.version;

  # Repositories
  defaultExtra = genAttrs resolvedSearch.right (name: mkRepo name (findFile nixPath name));
  mkNur = repo: (import nur { pkgs = repo; }) // { _local = true; _used = repoName repo; _name = "NUR packages${optionalString (! repoEq repo stable) " using ${repoName repo}"}"; };
  pin = rev: hash: mkRepo "pin ${rev}" (fetchgit { inherit hash rev; name = "nixpkgs-pin-${rev}"; url = "https://github.com/NixOS/nixpkgs.git"; });
  pr = id: hash: mkRepo "PR #${toString id}" (fetchgit { inherit hash; name = "nixpkgs-pr-${toString id}"; url = "https://github.com/NixOS/nixpkgs.git"; rev = "refs/pull/${toString id}/head"; });
  resolvedSearch = partition (name: (tryEval (pathExists (findFile nixPath name))).value) search;

  # Compile cache
  ccacheConfig = ''
    export CCACHE_COMPRESS='1'
    export CCACHE_DIR='/var/cache/ccache'
    export CCACHE_FILECLONE='1'
    export CCACHE_SLOPPINESS='random_seed'
    export CCACHE_UMASK='007'
  '';

  # Functions
  resolve = scope: pname:
    spec@{
      # Namespacing
      recurseForDerivations ? false

      # Repository selection
    , condition ? null
    , dontEval ? false
    , release ? null
    , search ? null
    , target ? stable
    , version ? null

      # Package defaults
    , deps ? { }

      # Compile cache
    , ccache ? false

      # Package attribute overlay
    , broken ? null
    , gappsWrapperArgs ? null
    , overlay ? null
    , patch ? null

      # Wrapper
    , args ? [ ]
    , env ? { }

      # Package input override
    , ...
    }:
    let
      # Package input override
      override =
        removeAttrs spec (attrNames (functionArgs (resolve scope pname)))
        // optionalAttrs ccache { stdenv = ccacheStdenv; };

      # Dependent parameters
      overlay' = if broken == null && overlay == null then null else
      composeOverrides
        (a: recursiveUpdate a { meta.broken = a.meta.broken or false || (defaultTo (const false) broken) a; })
        (defaultTo (const { }) overlay);

      # Mode
      doOverlay = gappsWrapperArgs != null || overlay' != null || patch != null;
      doOverride = ! isEmpty override;
      doPythonPackages = isPythonPackages scope;
      doWrapper = ! isEmpty wrapperArgs;

      # Package selection
      path = if doPythonPackages then [ pname ] else scope ++ [ pname ];
      fullName = showAttrPath (optional doPythonPackages "pythonPackages" ++ path);
      files = [ (library + "/${fullName}.local.pkg.nix") (library + "/${fullName}.pkg.nix") ];
      getVersion = r: if hasAttrByPath path r then (getAttrFromPath path r).version else null;
      findGreatest = predicate: default: candidates:
        let viable = filter predicate candidates; version = last (naturalSort (map getVersion viable)); in
        findFirst (r: getVersion r == version) default viable;
      packageSuffices = p:
        let p' = if overlay' == null then p else p.overrideAttrs overlay'; in
        (tryEval p').success
        && (! (p' ? meta && p'.meta.broken))
        && (version == null || versionSatisfied p.version version)
        && (condition == null || condition p)
        && (dontEval || ! p' ? outPath || (tryEval (ignoreLicense p').outPath).success);
      repoSuffices = r: r != null && (
        if isPath r then
          (pathExists r)
            && (release == null)
            && (packageSuffices (target.callPackage r deps))
        else
          (hasAttrByPath path r)
            && (release == null || versionSatisfied r.lib.trivial.release release)
            && ((isFunctor r path || isScope r path || isSet r path) || (packageSuffices (getAttrFromPath path r)))
      );
      base = uniqueBy repoName ([ target ] ++ (attrValues defaultExtra));
      nurs = optionals (nur != null) (map mkNur (base ++ extra));
      extra = if search == null then [ ] else imap1 (i: s: { _extra = i; _name = "search"; } // s) (toList search);
      repos = base ++ extra ++ nurs ++ files;
      repo = if doPythonPackages then scope else (if version == "∞" then findGreatest else findFirst) repoSuffices null repos;
      ccacheStdenv = repo.ccacheStdenv.override { extraConfig = ccacheConfig; };
      notFound = "${query} not found in ${concatMapStringsSep ", " repoName repos}${optionalString (length resolvedSearch.wrong > 0) " (Not searched: ${concatStringsSep ", " resolvedSearch.wrong})"}";
      package = throwIf (repo == null) notFound (
        if isPath repo then target.callPackage repo deps
        else getAttrFromPath path repo
      );

      # Package overlay
      package_with_overlay =
        if doOverlay then
          package.overrideAttrs
            (composeOverrides
              (a:
                (optionalAttrs (patch != null) { patches = a.patches or [ ] ++ (toList patch); }) //
                (optionalAttrs (gappsWrapperArgs != null) { preFixup = a.preFixup or "" + "\ngappsWrapperArgs+=(${gappsWrapperArgs})"; })
              )
              (defaultTo (const { }) overlay')
            )
        else package;

      # Package override
      package_with_overlay_with_override =
        if doOverride then package_with_overlay.override override
        else package_with_overlay;

      # Wrapper
      wrapperArgs =
        (map (a: "--add-flags ${escapeShellArg a}") args)
        ++ (mapAttrsToList (k: v: "--set ${escapeShellArg k} ${escapeShellArg v}") env);
      package_with_overlay_with_override_with_wrapper =
        if doWrapper then
          symlinkJoin
            {
              name = "${pname}-wrapper";
              paths = [ package_with_overlay_with_override ];
              buildInputs = [ makeWrapper ];
              postBuild = ''
                for program in $out/bin/*; do
                  wrapProgram "$program" ${concatStringsSep " " wrapperArgs}
                done
              '';
            }
        else package_with_overlay_with_override;

      # Report
      query = fullName +
        (optionalString (version != null) " ${version}") +
        (optionalString (release != null) " of NixOS ${release}");
      summary = "Resolved ${query}" +
        (optionalString (package_with_overlay_with_override_with_wrapper ? version) " to ${package_with_overlay_with_override_with_wrapper.version}") +
        (optionalString (doOverlay || doOverride || doWrapper) " with override") +
        (optionalString (condition != null) " meeting condition") +
        (optionalString (! repoEq repo stable) " via ${repoName repo}");
      unnecessary = repo != null && (repoEq repo stable) && !doOverlay && !doOverride && !doWrapper && version != "∞";
      unnecessaryFiles = concatStringsSep ", " (optionals (repo != null && ! isLocal repo) (filter pathExists files));
      unnecessarySearches = concatMapStringsSep ", " repoName (filter (r: repo != null && r._extra > repo._extra or 0 && ! (repo ? _used && repo._used == repoName r)) extra);
    in
    if pname == "pythonPackages" then
      nameValuePair "pythonPackagesExtensions"
        (stable.pythonPackagesExtensions ++ [
          (_: pythonPackages:
            mapAttrs' (resolve pythonPackages) spec)
        ])
    else
      nameValuePair pname (
        if isScope repo path then
          (getAttrFromPath path stable).overrideScope (_: _: mapAttrs' (resolve path) spec)
        else if recurseForDerivations || (isSet repo path) then
          (attrByPath path { } repo) // (mapAttrs' (resolve path) (removeAttrs spec [ "recurseForDerivations" ]))
        else
          (throwIf (unnecessaryFiles != "") "${summary} and it longer requires ${unnecessaryFiles}")
            (throwIf (unnecessarySearches != "") "${summary} and it longer requires searching ${unnecessarySearches}")
            (throwIf unnecessary "${summary} and it no longer requires an override")
            (info summary package_with_overlay_with_override_with_wrapper)
      )
  ;
in
defaultExtra // {
  inherit pin pr;

  any = { };

  namespaced = mapAttrs (_: recurseIntoAttrs);

  specify = mapAttrs' (resolve [ ]);
}
