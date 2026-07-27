{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "rpi_ws281x";
  version = "4b41a83c6aeb945cd7cdf6e1b4f764f4943f4b1f";

  src = fetchFromGitHub {
    owner = "jgarff";
    repo = name;
    rev = version;
    hash = "sha256-b+xFG1OAx1n7kHYgOecj4CyLgpjKTT+D1rphSaxzH/g=";
  };

  cmakeFlags = [ "-DBUILD_SHARED=off" "-DBUILD_TEST=off" ];

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    homepage = "https://github.com/jgarff/rpi_ws281x";
    description = "Userspace Raspberry Pi PWM library for WS281X LEDs";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.bsd2;
  };

}
