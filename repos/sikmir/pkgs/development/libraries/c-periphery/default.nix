{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "c-periphery";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "vsergeev";
    repo = "c-periphery";
    rev = "v${version}";
    hash = "sha256-uUSXvMQcntUqD412UWkMif0wLxPhpPdnMb96Pqqh/B4=";
  };

  postPatch = ''
    substituteInPlace src/libperiphery.pc.in \
      --replace '=''${prefix}/' '=' \
      --replace '=''${exec_prefix}/' '='
  '';

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A C library for peripheral I/O (GPIO, LED, PWM, SPI, I2C, MMIO, Serial) in Linux";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
