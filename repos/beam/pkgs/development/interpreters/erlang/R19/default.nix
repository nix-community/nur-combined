{ lib, openssl_1_0_2, wxGTK30, beamLib, util, deriveErlangFeatureVariants }:

let
  # compile_fails = [
  #   # R19.0 failed on linux with error:
  #   # ../bin/diameterc: /usr/bin/env: bad interpreter: No such file or directory
  #   ./R19.0.nix
  # ];

  # releases = lib.lists.subtractLists compile_fails
  #   (util.findByPrefix ./. (baseNameOf ./.));

  releases = [ ];

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
