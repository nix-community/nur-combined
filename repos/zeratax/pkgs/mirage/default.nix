{ stdenv, lib, mkDerivation ? false, fetchFromGitHub, qtbase ? false, qt5
, qmake ? false, python3, pyotherside, libmediainfo, libjpeg, libtiff, libwebp
, openjpeg, olm, zlib, wrapQtAppsHook, myPython3Packages }:

with python3.pkgs;

mkDerivation rec {
  version = "0.5.2";
  pname = "mirage";

  src = fetchFromGitHub {
    owner = "mirukana";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "0i891fafdncdz1xg6nji80jb86agsrbdvai9nwf1yy126q7piryv";
  };

  buildInputs = [
    libjpeg
    libmediainfo
    libtiff
    libwebp
    olm
    openjpeg
    pyotherside
    qt5.qtgraphicaleffects
    qt5.qtimageformats
    qt5.qtquickcontrols2
    qt5.qtsvg
    qtbase
    zlib
  ];
  nativeBuildInputs = [ python3.pkgs.wrapPython wrapQtAppsHook ];
  propagatedBuildInputs = [
    aiofiles
    appdirs
    async_generator
    blist
    cairosvg
    filetype
    lxml
    mistune
    myPython3Packages.html-sanitizer
    myPython3Packages.matrix-nio
    myPython3Packages.pyfastcopy
    pillow
    pymediainfo
    setuptools
  ];

  preBuild = ''
    makeFlagsArray+=(CFLAGS="-march=native -O2 -pipe")
    qmake PREFIX=$out mirage.pro
  '';

  postInstall = ''
    buildPythonPath "$out $propagatedBuildInputs"
  '';

  dontWrapQTApps = true;
  postFixup = ''
    wrapQtApp $out/bin/mirage --prefix PYTHONPATH : "$program_PYTHONPATH"
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = "https://github.com/mirukana/mirage/";
    description =
      " A fancy, customizable, keyboard-operable Qt/QML+Python Matrix chat client for encrypted and decentralized communication.";
    license = licenses.lgpl3;
    # maintainers = with maintainers; [ zeratax ];
  };
}

