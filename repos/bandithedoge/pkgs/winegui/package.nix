{
  sources,

  lib,
  stdenv,

  cmake,
  gtkmm4,
  ninja,
  nlohmann_json,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.winegui) pname src;
  version = lib.removePrefix "v" sources.winegui.version;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    gtkmm4
    nlohmann_json
  ];

  meta = {
    description = "A user-friendly WINE manager";
    homepage = "https://gitlab.melroy.org/melroy/winegui";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "winegui";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
