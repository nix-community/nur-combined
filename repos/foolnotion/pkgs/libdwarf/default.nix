{ lib, stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "libdwarf";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "davea42";
    repo = "libdwarf-code";
    rev = "v${version}";
    hash = "sha256-Ba2CowZDIsy6tiIiSKpxvlNJesTVEMWhO/3pjEoxmUg=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    homepage = "https://github.com/jeremy-rifkin/libdwarf-code";
    platforms = lib.platforms.unix;
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.atry ];
  };
}
