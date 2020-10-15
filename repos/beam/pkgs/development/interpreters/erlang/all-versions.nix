{ pkgs, fetchpatch, callPackage, wxGTK30, openssl_1_0_2, lib, util, mainOnly }:

let
  beamLib = callPackage ../../beam-modules/lib.nix { };

  overrideFeature = basePkg: featureString: featureFlag:
    let
      pkgPath = util.makePkgPath "erlang" basePkg.version featureString;
      pkgName = util.makePkgName "erlang" basePkg.version featureString;

      featurePkg = basePkg.override featureFlag;
      namedPkg = featurePkg.overrideAttrs (o: { name = pkgName; });
    in {
      name = pkgPath;
      value = namedPkg;
    };

  deriveErlangFeatureVariants = release: buildOpts: featureOpts:
    let
      basePkg = beamLib.callErlang release buildOpts;
      featureStringToFlags = util.combineFeatures featureOpts "_";
    in lib.attrsets.mapAttrs' (overrideFeature basePkg) featureStringToFlags;

  folders = builtins.attrNames
    (lib.attrsets.filterAttrs (_: type: type == "directory")
      (builtins.readDir ./.));
  majorVersions = map (f: ./. + ("/" + f)) folders;

  releasesPerMajorVersion = map (r:
    callPackage r {
      inherit beamLib util mainOnly deriveErlangFeatureVariants;
    }) majorVersions;

in util.mergeListOfAttrs releasesPerMajorVersion
