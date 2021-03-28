{ stdenv, lib, fetchurl, rpmextract, autoPatchelfHook
, zlib
}:
stdenv.mkDerivation rec {
  pname = "ilorest";
  version = "3.1.1-11";

  src = fetchurl {
    url = "https://downloads.linux.hpe.com/SDR/repo/${pname}/RedHat/8/x86_64/current/${pname}-${version}.x86_64.rpm";
    sha256 = "1a1c2lh5hag2amcsdc11h50a7jv03n5kzd16l9fs9crpvb3a1jvm";
  };

  nativeBuildInputs = [
    rpmextract autoPatchelfHook
  ];

  buildInputs = [
    zlib stdenv.cc.cc.lib
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
