{ lib, python3Packages, qt5, sources }:

python3Packages.buildPythonApplication {
  pname = "map-stylizer-unstable";
  version = lib.substring 0 10 sources.map-stylizer.date;

  src = sources.map-stylizer;

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
    inherit (sources.map-stylizer) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
