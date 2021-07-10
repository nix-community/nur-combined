self: super: {
  qt5ct = super.qt5ct.overrideAttrs(oldAttrs: rec {
    version = "1.2";

    src = with super; fetchurl {
      url = "mirror://sourceforge/${oldAttrs.pname}/${oldAttrs.pname}-${version}.tar.bz2";
      sha256 = "HePwbm1dB0a/GalJ5WzAS1O9vBgpTzjLIHWfNQBrhy4=";
    };

    buildInputs = oldAttrs.buildInputs ++ (with super.libsForQt5; [
      qtquickcontrols2 kconfig kconfigwidgets kiconthemes
    ]);

    nativeBuildInputs = with super; with super.libsForQt5; [
      cmake wrapQtAppsHook qttools
    ];
  
    patches = [
      ./qt5ct-shenanigans.patch
      ./qt5ct-fix-installation.patch
    ];
  
    cmakeFlags = with super.libsForQt5; [
      "-DPLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
    ];
  });
}
