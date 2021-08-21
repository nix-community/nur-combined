self: super: {
  qt5ct = super.qt5ct.overrideAttrs(oldAttrs: rec {
    version = "1.3";

    src = with super; fetchurl {
      url = "mirror://sourceforge/${oldAttrs.pname}/${oldAttrs.pname}-${version}.tar.bz2";
      sha256 = "3UQ7FOWQr/dqFuExbVbmiIguMkjEcN9PcbyVJWnzw7w=";
    };

    buildInputs = oldAttrs.buildInputs ++ (with super.libsForQt5; [
      qtquickcontrols2 kconfig kconfigwidgets kiconthemes
    ]);

    nativeBuildInputs = with super; with super.libsForQt5; [
      cmake wrapQtAppsHook qttools
    ];
  
    patches = [
      ./qt5ct-shenanigans.patch
    ];
  
    cmakeFlags = with super.libsForQt5; [
      "-DPLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
    ];
  });
}
