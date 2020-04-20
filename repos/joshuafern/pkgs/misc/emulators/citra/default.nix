{ stdenv, mkDerivation, lib, fetchgit, cmake, SDL2, qtbase, qtmultimedia, boost
}:

mkDerivation {
  pname = "citra";
  version = "unstable-2020-04-20";

  # Submodules
  src = fetchgit {
    url = "https://github.com/citra-emu/citra";
    rev = "d5a962cb8101fdc0bb9722a1be1a9b8d2f77e2e9";
    sha256 = "0fqm0p5qip231g0q2pxls8bx629nqsaxx6b5pqb39rqsk3j9gsya";
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ SDL2 qtbase qtmultimedia boost ];

  preConfigure = ''
    # Trick configure system.
    sed -n 's,^ *path = \(.*\),\1,p' .gitmodules | while read path; do
      mkdir "$path/.git"
    done
  '';

  meta = with stdenv.lib; {
    homepage = "https://citra-emu.org";
    description = "An open-source emulator for the Nintendo 3DS";
    license = licenses.gpl2;
    maintainers = with maintainers; [ abbradar ];
    platforms = platforms.linux;
  };
}
