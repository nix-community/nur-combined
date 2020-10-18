{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants }:

let
  # Remove R18 because rebar3 support R19+
  releases = [ ];
  # releases = util.findByPrefix ./. (baseNameOf ./.);

  buildOpts = {
    wxGTK = wxGTK30;
    openssl = openssl_1_0_2;
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
