{ buildArb, fetchsvn, pkgconfig, arbcore, arbcommon, glib }:
buildArb rec {
  version = "6.0.6";
  name = "arb-sl-cb-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/SL/CB";
    rev = "18244";
    sha256 = "sha256:05ml6a5f9gm3zhn6df8591r1fdh9jz6p07103rmfxkf4j1sgbib2";
  };

  MAIN="CL.a";

  nativeBuildInputs = [ pkgconfig arbcore arbcommon glib ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags glib-2.0)"
  '';

  installPhase = ''
    mkdir -p $out/include/
    mkdir -p $out/lib/
    cp *.h $out/include/
    cp CL.a $out/lib/
  '';
}

