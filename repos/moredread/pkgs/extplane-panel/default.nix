{ stdenv, lib, fetchFromGitHub, wrapQtAppsHook, qmake, qtsvg, qtquickcontrols2 }:

let
  extplane_src = fetchFromGitHub {
    owner = "vranki";
    repo = "ExtPlane";
    rev = "3b827988bdef0c2917396f4d6c38454c54304af9";
    sha256 = "1dmh6aaghg1ib5ccppnwvqkdny6c11mmrcjwdq6fmd57x1w5q7pn";
  };
in stdenv.mkDerivation rec {
  name = "extplane-panel-${version}";
  version = "20200302";

  src = fetchFromGitHub {
    owner = "vranki";
    repo = "ExtPlane-Panel";
    rev = "8aa0e2eca963564c03f707c29707ef5ca447ebd9";
    sha256 = "081v11ma4k42lzz6k9wxaajy40qd8722fxjbrwmv2aphchh6jy41";
  };

  prePatch = ''
    cp -r ${extplane_src} ../ExtPlane
    substituteInPlace qmlui/qmlui.pro \
      --replace "/usr/" "$out/"
    cat qmlui/qmlui.pro
    substituteInPlace widgetui/widgetui.pro \
      --replace "/usr/" "$out/"
  '';

  nativeBuildInputs = [ qmake wrapQtAppsHook ];
  buildInputs = [ qtsvg qtquickcontrols2 ];

  enableParallelBuilding = true;

  meta = {
    description = "WIP";
    #license = lib.licenses.gpl3;
  };
}
