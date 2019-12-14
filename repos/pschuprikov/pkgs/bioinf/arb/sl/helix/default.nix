{ buildArb, fetchsvn, pkgconfig, arbcore, arbcommon, glib, arbdb }:
buildArb rec {
  version = "6.0.6";
  name = "helix-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/SL/HELIX";
    rev = "18244";
    sha256 = "sha256:0aynzi2iwql8xysiii7ip4bhynir86cqja6xb0skb7d4ns3gbv11";
  };

  MAIN="HELIX.a";

  nativeBuildInputs = [ pkgconfig arbcore arbcommon arbdb glib ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags glib-2.0)"
  '';

  installPhase = ''
    mkdir -p $out/include/
    mkdir -p $out/lib/
    cp *.hxx $out/include/
    cp HELIX.a $out/lib/
  '';
}

