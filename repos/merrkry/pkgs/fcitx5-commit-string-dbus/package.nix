{
  lib,
  stdenv,
  cmake,
  extra-cmake-modules,
  fcitx5,
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-commit-string-dbus";
  version = "0.1.0";

  src = ./.;

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    fcitx5
  ];

  meta = {
    description = "Fcitx5 addon exposing a D-Bus method to commit text";
    homepage = "https://github.com/merrkry/nur-packages";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
