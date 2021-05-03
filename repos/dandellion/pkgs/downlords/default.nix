{ lib, stdenv, fetchzip, makeWrapper, jdk16, steam-run, ... }:

stdenv.mkDerivation rec {

  pname = "downlords-faf-client";
  version = "v1.4.3";

  src = fetchzip {
    url = "https://github.com/FAForever/downlords-faf-client/releases/download/${version}/dfc_unix_${lib.stringAsChars (x: if x == "." then "_" else if x == "v" then "" else x) version}.tar.gz";
    sha256 = "146p9r3fk4ini8xhbb24m8h6wrcw3dwcjj9j4jxc6l60pv3qsscd";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk16 ];

  installPhase = ''
    mkdir -p $out/lib/ $out/bin
    cp -r ${src} $out/lib/downlords

    makeWrapper $out/lib/downlords/downlords-faf-client $out/bin/dowlords \
      --set INSTALL4J_JAVA_HOME "${jdk16}/lib/openjdk" \
      --set PWD $out/lib/downlords \
      --run "cd $out/lib/downlords"
  '';

}
