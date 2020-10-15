{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants
, mainOnly }:

let
  compile_fails = [
    # R19.0 failed on linux with error:
    # ../bin/diameterc: /usr/bin/env: bad interpreter: No such file or directory
    ./R19.0.nix
  ];

  releases = lib.lists.subtractLists compile_fails
    (util.findByPrefix ./. (baseNameOf ./.));

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
