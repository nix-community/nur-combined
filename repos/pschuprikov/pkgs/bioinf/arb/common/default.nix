{ buildArb, fetchsvn }:
buildArb rec {
  version = "6.0.6";
  name = "arbcommon-${version}";
  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/";
    rev = "18244";
    sha256 = "sha256:1cdl3nm4id6dv8az1ngiknk93vnmy3sdijhajfs0w83b3aw6qifs";
  };

  buildPhase = ''
    runHook preBuild

    pushd SOURCE_TOOLS
    echo "''${makeFlagsArray[@]}"
    make "''${makeFlagsArray[@]}" arb_main_cpp.o
    make "''${makeFlagsArray[@]}" arb_main_c.o
    popd
  '';

  installPhase = ''
    mkdir -p $out/include/
    cp TEMPLATES/*.h $out/include/
    cp ARBDB/arbdb_base.h $out/include
    cp WINDOW/aw_awar_defs.hxx $out/include

    mkdir -p $out/lib/
    cp SOURCE_TOOLS/arb_main_c.o SOURCE_TOOLS/arb_main_cpp.o $out/lib/

    mkdir -p $out/bin/
    cp SOURCE_TOOLS/mv_if_diff $out/bin/
  '';
}

