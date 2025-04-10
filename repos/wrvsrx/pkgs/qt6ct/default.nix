{
  qt6ct,
  cmake,
  fetchFromGitHub,
  qtdeclarative,
  kconfig,
  kcolorscheme,
  kiconthemes,
  wrapQtAppsHook,
  qttools,
  qtbase,
}:
qt6ct.overrideAttrs (oldAttrs: {
  src = fetchFromGitHub {
    owner = "ilya-fedin";
    repo = "qt6ct";
    tag = oldAttrs.version;
    sha256 = "sha256-ePY+BEpEcAq11+pUMjQ4XG358x3bXFQWwI1UAi+KmLo=";
  };

  buildInputs = oldAttrs.buildInputs ++ [
    qtdeclarative
    kconfig
    kcolorscheme
    kiconthemes
  ];

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
    qttools
  ];

  cmakeFlags = [
    "-DPLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];
})
