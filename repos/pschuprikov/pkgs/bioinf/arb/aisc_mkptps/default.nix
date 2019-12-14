{ buildArb, fetchsvn, arbcommon, arbcore }:
buildArb rec {
  version = "6.0.6";
  name = "arbaisc_mkptps-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/AISC_MKPTPS";
    rev = "18244";
    sha256 = "sha256:1si8qdrhj8h7j4fx1f935k5wc9i10l6l8z4g4xwiyjnwx4p4a112";
  };

  buildInputs = [ arbcommon arbcore ];

  makeFlags = [ "use_ARB_main=${arbcommon}/lib/arb_main_cpp.o" ];

  installPhase = ''
    mkdir -p $out/bin/
    cp aisc_mkpt $out/bin/
  '';
}

