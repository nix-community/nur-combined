{ mkDerivation, lib, fetchgit,
  extra-cmake-modules,
  cmake,
  qttools,
  qtx11extras,
  kguiaddons,
  kconfigwidgets,
  kcoreaddons,
  kwindowsystem,
  kcrash,
  kinit,
  kwin,
  epoxy,
  xorg
}:

mkDerivation rec {
  pname = "kde-rounded-corners";
  version = "unstable";
  name = "${pname}-${version}";

  src = fetchgit {
     url = "https://github.com/alex47/KDE-Rounded-Corners.git";
     sha256 = "0dg0c81alic0n5iar9676lqp9q940fkrsd3pargjs7p2f0jfbcaw";
  };

  buildInputs = [ qttools qtx11extras kguiaddons kconfigwidgets kcoreaddons kwindowsystem kcrash kinit kwin epoxy xorg.libpthreadstubs xorg.libXdmcp];

  nativeBuildInputs = [ cmake extra-cmake-modules kcoreaddons ];

  cmakeFlags = [ "-DQT5BUILD=ON" "-DMODULEPATH=lib/qt-5.12/plugins/" "-DDATAPATH=share/" "-DSERVICEPATH=share/kservices5/"];

  patches = [./CMakeLists.txt.patch];

  meta = with lib; {
    description = "Rounds the corners of your windows";
    homepage = https://github.com/alex47/KDE-Rounded-Corners;
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = [ maintainers.ysndr ];
  };

}
