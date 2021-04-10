{ callPackage }:

{
  edmarketconnector = callPackage ./edmarketconnector { };

  obspy = callPackage ./obspy { };
}
