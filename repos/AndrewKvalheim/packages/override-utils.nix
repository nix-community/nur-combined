{ stable }:

let
  inherit (builtins) attrNames elemAt filter functionArgs isAttrs isPath length mapAttrs match pathExists removeAttrs toJSON tryEval;
  inherit (stable) callPackage fetchgit makeWrapper symlinkJoin;
  inherit (stable.lib) attrByPath concatMapStringsSep concatStringsSep const escapeShellArg findFirst getAttrFromPath hasAttrByPath imap1 info mapAttrsToList optionalAttrs optionalString recurseIntoAttrs showAttrPath throwIf toList versionAtLeast;

  # Utilities
  composeOverrides = f1: f2: a0: let o1 = f1 a0; o2 = f2 (a0 // o1); in o1 // o2;
  isEmpty = attrs: length (attrNames attrs) == 0;
  isLocal = r: isPath r || r._name or null == "NUR packages";
  isStable = r: isAttrs r && ! r ? "_name";
  mkRepo = name: path: (import path { inherit (stable) config; overlays = [ ]; }) // { _name = name; };
  repoName = r: if isPath r then toString r else r._name or "stable";
  versionMeetsSpec = candidate: spec:
    let parts = match "^([^[:alnum:]]+)?(.+)$" spec; operator = elemAt parts 0; version = elemAt parts 1; in
    if operator == null then candidate == version
    else if operator == "≥" then versionAtLeast candidate version
    else throw "version operator not implemented: ${toJSON operator}";

  # Repositories
  nur = (import ../nur.nix { pkgs = stable; }) // { _name = "NUR packages"; };
  pin = rev: hash: mkRepo "pin ${rev}" (fetchgit { inherit hash rev; name = "nixpkgs-pin-${toString rev}"; url = "https://github.com/NixOS/nixpkgs.git"; });
  pr = id: hash: mkRepo "PR #${toString id}" (fetchgit { inherit hash; name = "nixpkgs-pr-${toString id}"; url = "https://github.com/NixOS/nixpkgs.git"; rev = "refs/pull/${toString id}/head"; });
  unstable =
    if (tryEval (pathExists <unstable>)).value then mkRepo "unstable" <unstable>
    else info "No unstable channel found" null;

  # Functions
  resolve = scope: pname:
    spec@{
      # Namespacing
      recurseForDerivations ? false

      # Repository selection
    , condition ? null
    , release ? null
    , search ? null
    , version ? null

      # Package defaults
    , deps ? { }

      # Package attribute overlay
    , gappsWrapperArgs ? null
    , overlay ? null
    , patch ? null

      # Wrapper
    , env ? null

      # Package input override
    , ...
    }:
    let
      # Implicit arguments
      override = removeAttrs spec (attrNames (functionArgs (resolve scope pname)));

      # Specification
      doOverlay = gappsWrapperArgs != null || overlay != null || patch != null;
      doOverride = ! isEmpty override;
      doWrapper = env != null;

      # Package selection
      path = scope ++ [ pname ];
      fullName = showAttrPath path;
      file = ./. + "/${fullName}.nix";
      suffices = r: r != null && hasAttrByPath path r
        && (release == null || versionMeetsSpec r.lib.trivial.release release)
        && (version == null || versionMeetsSpec (getAttrFromPath path r).version version)
        && (condition == null || condition (getAttrFromPath path r));
      extra = if search == null then [ ] else imap1 (i: s: { _extra = i; _name = "search"; } // s) (toList search);
      repos = [ stable unstable ] ++ extra ++ [ nur ];
      repo = findFirst suffices file repos;
      package =
        if isPath repo then
          throwIf (! pathExists repo) "${query} not found in ${concatMapStringsSep ", " repoName (repos ++ [repo])}"
            (callPackage repo deps)
        else getAttrFromPath path repo;

      # Package overlay
      package_with_overlay =
        if doOverlay then
          package.overrideAttrs
            (composeOverrides
              (a:
                (optionalAttrs (patch != null) { patches = a.patches or [ ] ++ (toList patch); }) //
                (optionalAttrs (gappsWrapperArgs != null) { preFixup = a.preFixup or "" + "\ngappsWrapperArgs+=(${gappsWrapperArgs})"; })
              )
              (if overlay == null then const { } else overlay)
            )
        else package;

      # Package override
      package_with_overlay_with_override =
        if doOverride then package_with_overlay.override override
        else package_with_overlay;

      # Wrapper
      package_with_overlay_with_override_with_wrapper =
        if doWrapper then
          symlinkJoin
            {
              name = "${pname}-wrapper";
              paths = [ package_with_overlay_with_override ];
              buildInputs = [ makeWrapper ];
              postBuild = ''
                for program in $out/bin/*; do
                  wrapProgram "$program" \
                    ${concatStringsSep " " (mapAttrsToList (k: v: "--set ${escapeShellArg k} ${escapeShellArg v}") env)}
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
        (optionalString (! isStable repo) " via ${repoName repo}");
      unnecessary = isStable repo && !doOverlay && !doOverride && !doWrapper;
      unnecessaryFile = ! isLocal repo && pathExists file;
      unnecessarySearches = concatMapStringsSep ", " repoName (filter (r: r._extra > repo._extra or 0) extra);
    in
    if hasAttrByPath (path ++ [ "overrideScope" ]) stable then
      (getAttrFromPath path stable).overrideScope (_: _: mapAttrs (resolve path) spec)
    else if recurseForDerivations || (attrByPath (path ++ [ "recurseForDerivations" ]) false repo) then
      (attrByPath path { } repo) // { recurseForDerivations = false; } // (mapAttrs (resolve path) spec)
    else
      (throwIf unnecessaryFile "${query} no longer requires ${file}")
        (throwIf (unnecessarySearches != "") "${query} no longer requires searching ${unnecessarySearches}")
        (throwIf unnecessary "${query} no longer requires an override")
        (info summary package_with_overlay_with_override_with_wrapper)
  ;
in
{
  inherit pin pr unstable;

  any = { }; # TODO: Can this be implied for all nonexistent packages? (e.g. via NixOS/nix#8187)

  namespaced = mapAttrs (_: recurseIntoAttrs);

  specify = mapAttrs (resolve [ ]);
}
