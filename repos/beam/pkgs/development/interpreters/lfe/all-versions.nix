{ lib, beamLib, erlang, buildRebar3, buildHex, annotateErlangInVersion, util
, mainOnly }:

let
  releases = [
    {
      nix = ./1.2.0.nix;
      isMain = true;
      maxOTPVersion = "19";
    }
    {
      nix = ./1.2.1.nix;
      isMain = false;
      maxOTPVersion = "19";
    }
    {
      nix = ./1.3.nix;
      isMain = true;
      maxOTPVersion = "21";
    }
  ];

  otpCompatibleRels = builtins.filter (r:
    builtins.compareVersions (lib.versions.major erlang.version) r.maxOTPVersion
    <= 0) releases;

  filteredByMain = builtins.filter (r: r.isMain || !mainOnly) otpCompatibleRels;

  pkgs = map (r: beamLib.callLFE r.nix { inherit erlang buildRebar3 buildHex; })
    filteredByMain;

  pairs = map (pkg: {
    name = util.snakeVersion pkg.name;
    value = annotateErlangInVersion pkg;
  }) pkgs;

in (builtins.listToAttrs pairs)
