{ lib, fetchFromGitHub, python3Packages, qt5 }:

python3Packages.buildPythonApplication rec {
  pname = "map-stylizer";
  version = "2020-06-30";

  src = fetchFromGitHub {
    owner = "Absolute-Tinkerer";
    repo = "map-stylizer";
    rev = "6279f40408aff823a4eb1071334bd2acd10cb921";
    hash = "sha256-vUMHdUn5IZkB21Wg83lRZ/HwSnmgzem4ZBjELcizNE0=";
  };

  patches = [ ./config.patch ];

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
    mkdir -p $site_packages
    cp -r src main.py $site_packages

    substituteInPlace $site_packages/main.py \
      --replace "'src'" "'$site_packages/src'"

    substituteInPlace $site_packages/src/core/constants.py \
      --replace "src/resources" "$site_packages/src/resources"

    makeWrapper ${(python3Packages.python.withPackages (ps: [ ps.pyqt5 ])).interpreter} $out/bin/map-stylizer \
      --set QT_QPA_PLATFORM_PLUGIN_PATH ${qt5.qtbase.bin}/lib/qt-*/plugins/platforms \
      --add-flags "$site_packages/main.py"
  '';

  meta = with lib; {
    description = "GUI written in Python to parse OSM (OpenStreetMap) files and render them onscreen";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
  };
}
