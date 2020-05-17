{ stdenv, mkDerivation, lib, fetchgit, cmake, SDL2, qtbase, qtmultimedia, boost, alsaLib
}:

mkDerivation {
  pname = "citra";
  version = "unstable-2020-05-13";

  # Submodules
  src = fetchgit {
    url = "https://github.com/citra-emu/citra";
    rev = "213c956b7ce15a2ceabceef7539b881b1934467c";
    sha256 = "0w72yybyfhfrmnkicwk2xmgl7nfmrvjvw02965rim9njzvy3cspg";
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ SDL2 qtbase qtmultimedia boost alsaLib ];

  preConfigure = ''
    # Trick configure system.
    sed -n 's,^ *path = \(.*\),\1,p' .gitmodules | while read path; do
      mkdir "$path/.git"
    done
  '';

  meta = with stdenv.lib; {
    homepage = "https://citra-emu.org";
    description = "An open-source emulator for the Nintendo 3DS";
    license = with licenses; [ 
      gpl2Plus
      # Icons
      cc-by-nd-30 cc0
    ];
    maintainers = with maintainers; [ abbradar joshuafern ];
    platforms = platforms.linux;
  };
}
