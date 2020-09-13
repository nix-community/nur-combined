{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants
, mainOnly }:

let
  releases = util.findByPrefix ./. (baseNameOf ./.);

  buildOpts = {
    wxGTK = wxGTK30;
    # Can be enabled since the bug has been fixed in https://github.com/erlang/otp/pull/2508
    parallelBuild = true;
  };

  featureOpts = if mainOnly then
    { }
  else {
    odbc = { odbcSupport = true; };
    javac = { javacSupport = true; };
    nox = { wxSupport = false; };
  };

  variantsPerReleases =
    map (r: deriveErlangFeatureVariants r buildOpts featureOpts) releases;

in util.mergeListOfAttrs variantsPerReleases
