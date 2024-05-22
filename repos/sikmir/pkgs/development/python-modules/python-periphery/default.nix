{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "python-periphery";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "vsergeev";
    repo = "python-periphery";
    rev = "v${version}";
    hash = "sha256-vRK1jeLG+z+yOYGGACO6dYSpzfO9NhNiThVTt35maaU=";
  };

  meta = with lib; {
    description = "A pure Python 2/3 library for peripheral I/O (GPIO, LED, PWM, SPI, I2C, MMIO, Serial) in Linux";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
