{ lib, stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation {
  pname = "libdwarf";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "libdwarf-code";
    rev = "520e20185262f96c9580cab157307b0890fc2c66";
    hash = "sha256-AlrdgUFPC9wQp851yHdwmCD/6dRvH/EphKCercO4wbs=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    homepage = "https://github.com/jeremy-rifkin/libdwarf-code";
    platforms = lib.platforms.unix;
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.atry ];
  };
}
