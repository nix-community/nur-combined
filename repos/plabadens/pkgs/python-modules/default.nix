{ callPackage }:

{
  edmarketconnector = callPackage ./edmarketconnector { };

  obspy = callPackage ./obspy { };

  prettymaps = callPackage ./prettymaps { };

  python-validity = callPackage ./python-validity { };
}
