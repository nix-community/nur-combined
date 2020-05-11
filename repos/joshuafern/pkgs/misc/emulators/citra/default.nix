{ stdenv, mkDerivation, lib, fetchgit, cmake, SDL2, qtbase, qtmultimedia, boost, alsaLib
}:

mkDerivation {
  pname = "citra";
  version = "unstable-2020-05-11";

  # Submodules
  src = fetchgit {
    url = "https://github.com/citra-emu/citra";
    rev = "d11d600b61e44599a3b7379727263396e51b6ef4";
    sha256 = "1f2bviffyiknw1sshqvnj3fhkhhwz0iaw9gshab5j3r6b2wd5473";
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
