{ callPackage, rebar, erlang, debugInfo, annotateErlangInVersion, util, mainOnly
}:

let
  beamLib = callPackage ../../beam-modules/lib.nix { };

  majorVersions =
    if mainOnly then [ ./1.10 ./1.9 ] else [ ./1.10 ./1.9 ./1.8 ./1.7 ./1.6 ];

  deriveElixirs = releases: minimumOTPVersion:
    if builtins.compareVersions erlang.version minimumOTPVersion >= 0 then
      let

        pkgs = map (r: beamLib.callElixir r { inherit rebar erlang debugInfo; })
          releases;

        pairs = map (pkg: {
          name = util.snakeVersion pkg.name;
          value = annotateErlangInVersion pkg;
        }) pkgs;

      in (builtins.listToAttrs pairs)
    else
      { };

  releasesPerMajorVersion =
    map (r: callPackage r { inherit deriveElixirs mainOnly; }) majorVersions;

in util.mergeListOfAttrs releasesPerMajorVersion
