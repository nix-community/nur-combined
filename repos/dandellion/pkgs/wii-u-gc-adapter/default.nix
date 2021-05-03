{ lib, stdenv, fetchFromGitHub, pkg-config, libusb1, libudev}:

stdenv.mkDerivation {
  pname = "wii-u-gc-adapter";
  version = "unstable-2020-07-22";

  src = fetchFromGitHub {
    owner = "ToadKing";
    repo = "wii-u-gc-adapter";
    rev = "63655a2611a50f653b66415e44f43a5313eb2921";
    sha256 = "03lwsxjfn4pjw6dyh4gzk5yx4dmgr46xmalx92qvq8allghvvy6s";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 libudev ];

  meta = with lib; {
    broken = true;
    homepage = "https://github.com/ToadKing/wii-u-gc-adapter";
    description = "Tool for using the Wii U GameCube Adapter on Linux";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
