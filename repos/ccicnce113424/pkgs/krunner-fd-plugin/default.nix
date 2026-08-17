{
  sources,
  version,
  lib,
  stdenv,
  cmake,
  ninja,
  kdePackages,
}:
stdenv.mkDerivation {
  inherit (sources) pname src;
  inherit version;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = with kdePackages; [
    extra-cmake-modules
    qtbase
    krunner
    kio
    kcmutils
  ];

  dontWrapQtApps = true;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "KRunner plugin to search for files using fd";
    homepage = "https://github.com/wangzk/krunner-fd-plugin";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    license = lib.licenses.lgpl2Plus;
  };
}
