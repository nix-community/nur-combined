{ lib, stdenv, fetchFromGitHub, autoreconfHook, gfortran, guile, pkg-config
} :

stdenv.mkDerivation rec {
  pname = "libctl";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "NanoComp";
    repo = pname;
    rev = "v${version}";
    sha256 = "03753gk0m2m16y2p6f9fv7l3sr9kspdfzyiv1q6830ky2hx7z5nx";
  };

  nativeBuildInputs = [
    autoreconfHook
    gfortran
    pkg-config
  ];

  buildInputs = [ guile ];

  configureFlags = [ "--enable-shared" ];

  meta = with lib; {
    description = "Guile-based library implementing flexible control files for scientific simulations";
    homepage = "https://github.com/NanoComp/libctl";
    license = with licenses; [ gpl2Only ];
    maintainers = [ maintainers.sheepforce ];
    platforms = platforms.linux;
  };
}
