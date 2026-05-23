{
  lib,
  stdenv,
  fetchgit,
  fixDarwinDylibNames,
  qt,
  maintainers,
  ...
}:
let
  qtVersion = lib.versions.major qt.qtbase.version;

  pname = "qwt-qt${qtVersion}";
  version = "6.3.0";

  rev = "v${version}";
  hash = "sha256-jMP3/Mtzc2NhF2i3ldZLNkwpKotSy/ubd3Er+6oUqiQ=";
in
stdenv.mkDerivation {
  inherit pname version;

  outputs = [
    "out"
    "dev"
  ];

  src = fetchgit {
    inherit hash rev;
    url = "git://git.code.sf.net/p/qwt/git";
  };

  dontWrapQtApps = true;

  propagatedBuildInputs = [
    qt.qtbase
    qt.qtsvg
    qt.qttools
  ];

  nativeBuildInputs = [
    qt.qmake
  ]
  ++ lib.optional stdenv.isDarwin [
    fixDarwinDylibNames
  ];

  postPatch = ''
    substituteInPlace qwtconfig.pri \
      --replace-fail "/usr/local/qwt-\$\$QWT_VERSION-dev" "$out"
  '';

  qmakeFlags = [
    "-after doc.path=$out/share/doc/qwt-${version}"
  ];

  meta = {
    inherit maintainers;
    description = "Qt widgets for technical applications.";
    homepage = "http://qwt.sourceforge.net/";
    # LGPL 2.1 plus a few exceptions (more liberal)
    license = [
      lib.licenses.lgpl2
      lib.licenses.qwtException
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
