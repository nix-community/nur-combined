{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./R22.3.nix ];

  buildOpts = {
    wxGTK = wxGTK30;
    # Can be enabled since the bug has been fixed in https://github.com/erlang/otp/pull/2508
    parallelBuild = true;
  };

  variantOpts = {
    "" = {
      odbcSupport = true;
      javacSupport = true;
      wxSupport = true;
    };
  };

  variantsPerReleases =
    map (r: deriveErlangFeatureVariants r buildOpts variantOpts) releases;

in util.mergeListOfAttrs variantsPerReleases
