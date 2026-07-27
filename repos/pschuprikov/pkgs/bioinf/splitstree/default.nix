{ lib, stdenv, fetchurl, makeWrapper, openjdk }:
stdenv.mkDerivation rec {
  version = "4.15.1";
  name = "SplitsTree-${version}";

  dontUnpack = true;

  src = 
    let uscore_version = lib.stringAsChars (x: if x == "." then "_" else x) version;
    in fetchurl {
      url = "https://software-ab.informatik.uni-tuebingen.de/download/splitstree4/splitstree4_unix_${uscore_version}.sh";
      sha256 = "sha256:1kj9wd913iwivq6bxwcgf09x007a5q59pw3dg62543yzawxr875z";
    };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    export INSTALL4J_JAVA_HOME=${openjdk.home}
    #sh $src -q -dir $out
    sh $src -q
    install -d $out/bin
    install -d $out/lib
    cp splitstree4/SplitsTree $out/bin
    cp -r splitstree4/jars splitstree4/.install4j $out/lib/
  '';

  postFixup = ''
    substituteInPlace $out/bin/SplitsTree \
      --replace "app_home=." "app_home=$out/lib"
    wrapProgram $out/bin/SplitsTree \
      --set INSTALL4J_JAVA_HOME ${openjdk.home}
  '';

  meta = {
    platforms = lib.platforms.linux;
    lincense = lib.licenses.unfree;
    broken = true;
  };
}
