{
  fetchFromGitHub, python3, python3Packages, gexiv2, gobject-introspection, wrapGAppsHook, qtbase, qt5, ffmpeg,
  enableSpellCheck ? false
}:

let
  pythonEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    pyqt5 #_with_qtwebkit
    pyqtwebengine
    pygobject3
    appdirs
    requests
    six
    pillow
    setuptools
    gpxpy
  ]
  ++ (if enableSpellCheck then with pythonPackages; [ pyenchant ] else [])
  );
in

  python3Packages.buildPythonApplication rec {
    pname = "photini";
    version = "2019.10.1";

    src = fetchFromGitHub {
      owner = "jim-easterbrook";
      repo = "Photini";
      rev = "${version}";
      sha256 = "19xm24vgfqis0bqrg5fc5jxf5yr1md5y49kb7q3792gihykl6yzm";
    };


    nativeBuildInputs = [ wrapGAppsHook qt5.wrapQtAppsHook ];
    buildInputs = [ gexiv2 ffmpeg gobject-introspection ];
    propagatedBuildInputs = [ pythonEnv ];


    postInstall = ''
      for program in $out/bin/*; do
        wrapQtApp $program --prefix PYTHONPATH : $PYTHONPATH
      done
    '';

  }
