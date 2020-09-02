{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants
, mainOnly }:

let
  releases = if mainOnly then [ ] else [ ./R16B02-basho.nix ];

  buildOpts = { };

  featureOpts = if mainOnly then { } else { odbc = { odbcSupport = true; }; };

  variantsPerReleases =
    map (r: deriveErlangFeatureVariants r buildOpts featureOpts) releases;

in util.mergeListOfAttrs variantsPerReleases
