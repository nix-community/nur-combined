{
  # keep-sorted start
  fetchgit,
  fetchzip,
  lib,
  repoRevToNameMaybe,
  # keep-sorted end
}: let
  inherit
    (lib)
    # keep-sorted start
    assertMsg
    attrNames
    functionArgs
    makeOverridable
    mapAttrs
    optionalAttrs
    overrideExisting
    revOrTag
    setFunctionArgs
    xor
    # keep-sorted end
    ;

  defaultGitArgs = {
    # keep-sorted start
    deepClone = false;
    fetchLFS = false;
    fetchSubmodules = false;
    forceFetchGit = false;
    leaveDotGit = null;
    postCheckout = "";
    rootDir = "";
    sparseCheckout = null;
    # keep-sorted end
  };

  nullableGitArgs = {
    leaveDotGit = false;
    sparseCheckout = [];
  };

  normalizedGitArgs = defaultGitArgs // nullableGitArgs;

  excludedGitArgNames = [
    "forceFetchGit"
  ];

  gitFunctionArgs = mapAttrs (_: _: true) defaultGitArgs;

  makeOverridableWithGitArgs = function:
    makeOverridable (setFunctionArgs function (gitFunctionArgs // functionArgs function));

  archiveFetcher =
    if fetchzip ? override
    then
      fetchzip.override {
        withUnzip = false;
      }
    else fetchzip;
in
  makeOverridableWithGitArgs (
    {
      # keep-sorted start
      did,
      domain ? "tangled.org",
      meta ? {},
      passthru ? {},
      rev ? null,
      tag ? null,
      # keep-sorted end
      ... # Hash agility and additional fetchgit arguments.
    } @ args:
      assert assertMsg (xor (tag != null) (rev != null))
      "fetchFromTangled requires exactly one of `rev` or `tag`."; let
        usesFetchGit =
          mapAttrs (
            name: default:
              if args ? ${name} && (nullableGitArgs ? ${name} -> args.${name} != null)
              then args.${name}
              else default
          )
          normalizedGitArgs
          != normalizedGitArgs;

        passedGitArgs = overrideExisting (removeAttrs defaultGitArgs excludedGitArgNames) args;

        sourcePosition =
          if args.meta.description or null != null
          then builtins.unsafeGetAttrPos "description" args.meta
          else if tag != null
          then builtins.unsafeGetAttrPos "tag" args
          else builtins.unsafeGetAttrPos "rev" args;

        baseUrl = "https://${domain}/${did}";

        sourceMeta =
          meta
          // {
            homepage = meta.homepage or baseUrl;
          }
          // optionalAttrs (sourcePosition != null) {
            position = "${sourcePosition.file}:${toString sourcePosition.line}";
          };

        forwardedArgs = removeAttrs args (
          [
            # keep-sorted start
            "did"
            "domain"
            "fetchSubmodules"
            "forceFetchGit"
            "rev"
            "tag"
            # keep-sorted end
          ]
          ++ (
            if usesFetchGit
            then excludedGitArgNames
            else attrNames gitFunctionArgs
          )
        );

        fetcher =
          if usesFetchGit
          then fetchgit
          else archiveFetcher;

        makeFetcherArgs = finalAttrs:
          forwardedArgs
          // (
            if usesFetchGit
            then
              passedGitArgs
              // {
                inherit passthru rev tag;

                url = baseUrl;

                derivationArgs = {
                  inherit did domain;
                };
              }
            else {
              extension = "tar.gz";
              url = "${baseUrl}/archive/${finalAttrs.rev}";

              derivationArgs = {
                inherit did domain tag;
                rev = fetchgit.getRevWithTag {
                  inherit (finalAttrs) tag;
                  rev = finalAttrs.revCustom;
                };
                revCustom = rev;
              };

              passthru =
                {
                  gitRepoUrl = baseUrl;
                }
                // passthru;
            }
          )
          // {
            meta = sourceMeta;
            name =
              args.name
              or (repoRevToNameMaybe finalAttrs.did (revOrTag finalAttrs.revCustom finalAttrs.tag) "tangled");
          };
      in
        fetcher makeFetcherArgs
  )
