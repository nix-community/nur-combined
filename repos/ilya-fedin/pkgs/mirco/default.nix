{ stdenv, lib, fetchFromGitHub, pkg-config, meson, ninja
, mir, libxkbcommon
}:

with lib;

stdenv.mkDerivation rec {
  pname = "mirco";
  version = "unstable-2022-04-01";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "mirco";
    rev = "ea472f3b9e24cdebd4abea6e4291c951dc2fe99b";
    sha256 = "sha256-oMMa3PSkOPoX3zXFuGCYAKF5dOuKG3bnHg7TUn2j9l4=";
  };

  nativeBuildInputs = [ pkg-config meson ninja ];

  buildInputs = [ mir libxkbcommon ];

  enableParallelBuilding = true;

  meta = {
    description = "A Mir based Wayland compositor";
    longDescription = ''
      A Mir based Wayland compositor forked from egmde
    '';
    license = [ licenses.gpl2Only licenses.gpl3Only licenses.lgpl2Only licenses.lgpl3Only ];
    platforms = platforms.linux;
    homepage = https://github.com/wmww/mirco;
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
