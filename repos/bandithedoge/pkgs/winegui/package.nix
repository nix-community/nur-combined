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
  version = "4.5.1";
  src = fetchFromGitHub {
    owner = "winegui";
    repo = "WineGUI";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4QBH/y5DAvMVjfCz5Vplao09bL9XEoHs1+LfDhQDlt0=";
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
