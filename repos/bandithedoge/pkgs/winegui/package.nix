{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  gtkmm4,
  ninja,
  nlohmann_json,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "winegui";
  version = "4.3.4";
  src = fetchFromGitHub {
    owner = "winegui";
    repo = "WineGUI";
    rev = "v${finalAttrs.version}";
    hash = "sha256-K0iZTAwei8o7PDV7b7yc3Ydkj1lwP7gOgH+aXsOo+uY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    gtkmm4
    nlohmann_json
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A user-friendly WINE manager";
    homepage = "https://gitlab.melroy.org/melroy/winegui";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "winegui";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
