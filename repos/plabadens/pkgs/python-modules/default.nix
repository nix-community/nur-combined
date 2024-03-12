{ callPackage }:

rec {
  btlewrap = callPackage ./btlewrap { };

  edmarketconnector = callPackage ./edmarketconnector { };

  miflora = callPackage ./miflora { inherit btlewrap; };

  python-validity = callPackage ./python-validity { };
}
