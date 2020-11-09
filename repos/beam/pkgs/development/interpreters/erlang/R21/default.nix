{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./R21.0.nix ];

  buildOpts = { wxGTK = wxGTK30; };

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
