{ callPackage }:

{
  dearpygui = callPackage ./dearpygui { };

  edmarketconnector = callPackage ./edmarketconnector { };

  obspy = callPackage ./obspy { };
}
