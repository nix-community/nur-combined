{ callPackage }:

{
  dearpygui = callPackage ./dearpygui { };

  edmarketconnector = callPackage ./edmarketconnector { };

  obspy = callPackage ./obspy { };

  python-validity = callPackage ./python-validity { };

  wxPython_4_1 = callPackage ./wxPython_4_1 { };
}
