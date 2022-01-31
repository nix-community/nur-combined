{ stdenv, lib, fetchFromGitHub, pkg-config, meson, ninja
, mir, libxkbcommon
}:

with lib;

stdenv.mkDerivation rec {
  pname = "mirco";
  version = "unstable-2020-10-29";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "mirco";
    rev = "86ed505e7824cce778d7b0f9100a571ecdbe350a";
    sha256 = "Lm6lSC69XqGA+2wm+zdRK1B4tIkTXstcSI6GxJZauIg=";
  };

  patches = [ ./fix-meson-language.patch ];

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
