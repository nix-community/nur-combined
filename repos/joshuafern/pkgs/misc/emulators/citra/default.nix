{ stdenv, mkDerivation, lib, fetchgit, cmake, SDL2, qtbase, qtmultimedia, boost, alsaLib
}:

mkDerivation {
  pname = "citra";
  version = "unstable-2020-04-24";

  # Submodules
  src = fetchgit {
    url = "https://github.com/citra-emu/citra";
    rev = "bc14f485c41311c8d4bc7d830a963ca45b9b9b25";
    sha256 = "1qgfjh1gap3sjgbfqz559wxmalwlc0iwiwj9d2zwi1ajj4lv8lqk";
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
    license = licenses.gpl2;
    maintainers = with maintainers; [ abbradar joshuafern ];
    platforms = platforms.linux;
  };
}
