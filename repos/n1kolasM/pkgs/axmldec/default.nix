{ stdenv, lib, cmake, fetchFromGitHub, boost, zlib, minizip }:
stdenv.mkDerivation {
  pname = "axmldec";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ytsutano";
    repo = "axmldec";
    rev = "cd0104b6853e850c516638bd65e50947191dea11";
    sha256 = "sha256-/ps52ScAd3iOdl8pzfEYDpbmYQ4kV1ZsS/tUoeZmvDQ=";
  };

  cmakeFlags = [
    "-DENABLE_APK_LOADING=NO"
  ];
  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost zlib minizip ];

  meta = with lib; {
    description = "Android Binary XML Decoder";
    homepage = https://github.com/ytsutano/axmldec;
    license = licenses.isc;
  };
}
