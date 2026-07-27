{ buildArb, fetchsvn, arbcommon, pkg-config, glib }:
buildArb rec {
  version = "6.0.6";
  name = "arbcore-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/CORE";
    rev = "18244";
    sha256 = "sha256:1zasbgq1vmvbll08qhp8mg8cl6sn14ydf0biyy0gid17rzgjf492";
  };

  nativeBuildInputs = [ pkg-config arbcommon glib ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags glib-2.0)"
  '';

  MAIN="libCORE.a";

  installPhase = ''
    mkdir -p $out/lib/
    cp libCORE.so $out/lib/
    mkdir -p $out/include/
    cp *.h $out/include/
  '';
}

