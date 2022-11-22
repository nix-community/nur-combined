{ callPackage }:

rec {
  btlewrap = callPackage ./btlewrap { };

  edmarketconnector = callPackage ./edmarketconnector { };

  miflora = callPackage ./miflora { inherit btlewrap; };

  prettymaps = callPackage ./prettymaps { };

  python-validity = callPackage ./python-validity { };
}
