{ lib, stdenv, fetchFromGitHub, cmake, qtbase, wrapQtAppsHook, qttools
, qtquickcontrols2, curl, libarchive, util-linux }:

stdenv.mkDerivation rec {
  name = "rpi-imager";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = name;
    rev = "v${version}";
    hash = "sha256-ITn31ENEf2bysgJgV3u+NNPXk1pfIkUyJWIvS2DOrzY=";
  };

  patches = [ ./remove-lsblk-test.patch ];

  nativeBuildInputs = [ cmake wrapQtAppsHook ];

  buildInputs = [ qtbase qttools qtquickcontrols2 curl libarchive util-linux ];

  meta = with lib; {
    homepage = "https://github.com/raspberrypi/rpi-imager";
    description = "Raspberry Pi Imaging Utility";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.asl20;
  };
}
