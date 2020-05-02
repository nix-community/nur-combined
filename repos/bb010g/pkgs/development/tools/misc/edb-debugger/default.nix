{ lib, mkDerivation, buildPackages, fetchFromGitHub
, boost, capstone, double-conversion, gdtoa-desktop, qtbase, qtsvg
, qtxmlpatterns
, enableGraph ? true
, graphviz ? null
}:

assert enableGraph -> graphviz != null;

mkDerivation rec {
  pname = "edb-debugger";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "eteran";
    repo = "edb-debugger";
    rev = version;
    sha256 = "1v1kvcvz6ywgs3q3v5zb9l3ag991rf4009vjdg7x3lifdccb4yn1";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    buildPackages.cmake
    buildPackages.pkgconfig
  ];
  buildInputs = [
    boost
    capstone
    double-conversion
    gdtoa-desktop
    qtbase
    qtsvg
    qtxmlpatterns
  ] ++ lib.optionals enableGraph [
    graphviz
  ];

  patches = [
    ./cmake-full-dirs.patch
    ./cmake-pkgconfig.patch
  ];

  postPatch = ''
    substituteInPlace ./CMakeLists.txt \
      --replace 'SEND_ERROR "The git submodules' '"The git submodules' \
      #
  '';

  meta = with lib; {
    description = "Cross platform AArch32/x86/x86-64 debugger";
    homepage = "https://github.com/eteran/edb-debugger";
    license = with licenses; gpl2Plus;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; all;
  };
}
