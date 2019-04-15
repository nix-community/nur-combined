{ mkDerivation, lib, fetchgit,
  extra-cmake-modules,
  cmake,
  qtx11extras,
  qtdeclarative,
  kdecoration,
  kcoreaddons,
  kguiaddons,
  kconfigwidgets,
  kwindowsystem,
}:

mkDerivation rec {
  pname = "breeze-blured";
  version = "unstable";
  name = "${pname}-${version}";

  src = fetchgit {
     url = "https://github.com/alex47/BreezeBlurred";
     rev = "a8d622d7f53cd63dc3b0b16f2b0e360769caa962";
     sha256 = "0kqchz5368q8vbyjw0k93q14221r3swzbzwdzavmakblxjz1rmxj";
  };

  buildInputs = [ ];

  nativeBuildInputs = [ extra-cmake-modules  qtx11extras kdecoration kcoreaddons kguiaddons qtdeclarative  kconfigwidgets
    kwindowsystem ];


  patches = [ ./radius.patch ];


  meta = with lib; {
    description = "BreezeBlurred is a fork of KDE Breeze window decoration written in Qt C++ ";
    homepage = https://github.com/alex47/BreezeBlurred;
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = [ maintainers.ysndr ];
  };


}
