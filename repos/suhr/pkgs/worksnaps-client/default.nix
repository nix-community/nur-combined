{ stdenv, fetchurl
, oraclejdk
, unzip
}:

stdenv.mkDerivation rec {
  name = "worksnaps-client-${version}";
  version = "1.1.20171130";

  src = fetchurl {
    url = "https://s3.amazonaws.com/worksnaps-download/WSClient-linux-1.1.20171130.zip";
    sha256 = "0zwqcis8769nvjvipkd70pgdir7ch8d7na3skhn2d8lgdivbi5cg";
  };

  buildInputs = [
    oraclejdk
  ];

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    mkdir -p $out/opt/Worksnaps
    cp -R bin/* $out/opt/Worksnaps

    mkdir $out/bin
    echo "#!/usr/bin/env bash" > $out/bin/wsclient
    echo "${oraclejdk}/bin/java -Djava.library.path=\"$out/opt/Worksnaps/lib\" -Dshowwidget=\"1\" -jar \"$out/opt/Worksnaps/WSClient.jar\"" >> $out/bin/wsclient
    chmod +x $out/bin/wsclient
  '';

  meta = with stdenv.lib; {
    description = "{Time Tracking} for Remote Work";
    homepage = https://www.worksnaps.com/;
    license = licenses.unfree;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
