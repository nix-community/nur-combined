{ lib, openssl_1_1, wxGTK30, beamLib, util, deriveErlangFeatureVariants }:

let
  releases = util.findByPrefix ./. (baseNameOf ./.);

  buildOpts = {
    wxGTK = wxGTK30;
    # Can be enabled since the bug has been fixed in https://github.com/erlang/otp/pull/2508
    parallelBuild = true;
    wxSupport = true;
  };

  variantOpts = {
    "" = {
      odbcSupport = true;
      javacSupport = true;
    };
  };

  variantsPerReleases =
    map (r: deriveErlangFeatureVariants r buildOpts variantOpts) releases;

in util.mergeListOfAttrs variantsPerReleases
