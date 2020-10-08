{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants
, mainOnly }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  # There's no way to compile even latest R17.5 on Linux with following error:
  # bash: ../bin/diameterc: /usr/bin/env: bad interpreter: No such file or directory
  releases = [ ];

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
