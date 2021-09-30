{ stdenv, lib, fetchurl, rpmextract, autoPatchelfHook
, zlib
}:
stdenv.mkDerivation rec {
  pname = "ilorest";
  version = "3.2.2-32";

  # TODO: Build from source
  src = fetchurl {
    url = "https://downloads.linux.hpe.com/SDR/repo/${pname}/current/${pname}-${version}.x86_64.rpm";
    hash = "sha256:1f1rh0ap1rmajf6asfvsxyfma2a60rd8qcsw389bwkvx52ax9zcr";
  };

  nativeBuildInputs = [
    rpmextract
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    rpmextract $src
  '';

  # TODO: Use install instead of cp
  installPhase = ''
    runHook preInstall

    cp -r usr $out
    cp -r etc $out/

    runHook postInstall
  '';

  meta = {
    description = "RESTful Interface Tool for HPE Servers";
    maintainers = with lib.maintainers; [ johnazoidberg ];
    license = lib.licenses.unfree;
    homepage = "https://downloads.linux.hpe.com/SDR/project/ilorest/";
    platforms = [ "x86_64-linux" ];
  };
}
