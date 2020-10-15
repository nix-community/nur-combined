{ lib, callPackage, rebar, erlang, debugInfo, annotateErlangInVersion, util
, mainOnly }:

let
  beamLib = callPackage ../../beam-modules/lib.nix { };

  folders = builtins.attrNames
    (lib.attrsets.filterAttrs (_: type: type == "directory")
      (builtins.readDir ./.));
  majorVersions = map (f: ./. + ("/" + f)) folders;

  deriveElixirs = releases: minOtp: maxOtp:
    let
      majorVer = lib.versions.major erlang.version;
      meetMin = builtins.compareVersions majorVer minOtp >= 0;
      meetMax = builtins.compareVersions majorVer maxOtp <= 0;
    in if meetMin && meetMax then
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
    map (r: callPackage r { inherit util deriveElixirs mainOnly; })
    majorVersions;

in util.mergeListOfAttrs releasesPerMajorVersion
