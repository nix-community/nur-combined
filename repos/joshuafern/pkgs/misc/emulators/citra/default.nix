{ stdenv, mkDerivation, lib, fetchgit, cmake, SDL2, qtbase, qtmultimedia, boost, alsaLib
}:

mkDerivation {
  pname = "citra";
  version = "unstable-2020-06-21";

  # Submodules
  src = fetchgit {
    url = "https://github.com/citra-emu/citra";
    rev = "7444c95132e40098ea4a5166b717f7af813cc385";
    sha256 = "0504g4fpc2azsb245x7r1p5llwjf0n0kr4hab32l4ylfh6phc3vs";
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
