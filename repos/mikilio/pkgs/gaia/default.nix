{
  fetchFromGitHub,
  stdenv,
  pkg-config,
  wafHook,
  eigen,
  libyaml,
  swig,
  libsForQt5,
}:
stdenv.mkDerivation {
  pname = "gaia";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "MTG";
    repo = "gaia";
    rev = "0d0942bf4748b40069977702715454ae084063c9";
    hash = "sha256-QK0xYCKmEigRjoP5abkxPtIGougy6WguFcLBJDJ71S4=";
  };

  nativeBuildInputs = [
    pkg-config
    wafHook
    # add one of these depending on the project:
    # cmake
    # autoconf
    # automake
    # libtool
    # gnumake
  ];

  buildInputs = [
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qttools
    eigen
    libyaml
    swig
  ];

  propagatedBuildInputs = [
  ];

  wafPath = "buildtools/bin/waf";

  dontWrapQtApps = true;

  # meta = {
  #   changelog = "https://github.com/wxWidgets/Phoenix/blob/wxPython-${version}/CHANGES.rst";
  #   description = "Cross platform GUI toolkit for Python, Phoenix version";
  #   homepage = "http://wxpython.org/";
  #   license = with lib.licenses; [
  #     lgpl2Plus
  #     wxWindowsException31
  #   ];
  # };
}
