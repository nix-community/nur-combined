{ buildArb, fetchsvn, arbcommon, arbcore }:
buildArb rec {
  version = "6.0.6";
  name = "aisc-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/AISC";
    rev = "18244";
    sha256 = "sha256:0nbsyhylgzbc323ayadbi8hix2na5jp7ikbpsdzwjgaipb0g2j7y";
  };

  buildInputs = [ arbcommon arbcore ];

  installPhase = ''
    mkdir -p $out/bin/
    cp aisc $out/bin/
    mkdir -p $out/share
    cp Makefile $out/share
  '';
}

