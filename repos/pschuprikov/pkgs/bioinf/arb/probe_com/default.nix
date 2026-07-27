{ buildArb, fetchsvn, pkg-config, arbcore, arbcommon, arbaisc, arbaisc_com, 
  arbaisc_mkptps, glib }:
buildArb rec {
  version = "6.0.6";
  name = "probe_com-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/PROBE_COM";
    rev = "18244";
    sha256 = "sha256:0vs5nhnc5y5qfb5sygbkmgmv7aa3v4j578kk65pddrkwfx5ndb68";
  };

  MAIN="client.a";

  nativeBuildInputs = [ pkg-config arbcore arbcommon glib arbaisc arbaisc_mkptps ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags glib-2.0)"
  '';

  preBuild = ''
    ln -sf ${arbaisc_com}/share/AISC AISC
    ln -sf ${arbaisc_com}/share/C C

    ln -sf GENH/aisc_com.h           PT_com.h
    ln -sf GENH/aisc_server_proto.h  PT_server_prototypes.h
    ln -sf GENH/aisc.h               PT_server.h

    makeFlagsArray+=(
      'AISC=${arbaisc}/bin/aisc'
      'AISC_MKPT=${arbaisc_mkptps}/bin/aisc_mkpt'
      'AISC_COMPILER=${arbaisc}/bin/aisc'
      'AISC_PROTOTYPER=${arbaisc_mkptps}/bin/aisc_mkpt'
      )
  '';

  installPhase = ''
    mkdir -p $out/lib/
    cp *.a $out/lib/
    mkdir -p $out/include/
    cp *.h $out/include/
  '';
}

