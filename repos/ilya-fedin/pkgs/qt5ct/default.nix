pkgs: with pkgs; with libsForQt5; qt5ct.overrideAttrs(oldAttrs: rec {
  version = "1.7";

  src = fetchurl {
    url = "mirror://sourceforge/${oldAttrs.pname}/${oldAttrs.pname}-${version}.tar.bz2";
    sha256 = "sha256-7VhUam5MUN/tG5/2oUjUpGj+m017WycnuWUB3ilVuNc=";
  };

  buildInputs = oldAttrs.buildInputs ++ ([
    qtquickcontrols2 kconfig kconfigwidgets kiconthemes
  ]);

  nativeBuildInputs =  [
    cmake wrapQtAppsHook qttools
  ];

  patches = [
    ./qt5ct-shenanigans.patch
  ];

  cmakeFlags = [
    "-DPLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];
})
