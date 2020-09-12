{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants
, mainOnly }:

let
  releases = if mainOnly then [ ./R18.0.nix ] else [ ./R18.0.nix ];

  buildOpts = {
    wxGTK = wxGTK30;
    openssl = openssl_1_0_2;
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
