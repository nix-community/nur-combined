{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ninja,
  python3,
  kdePackages,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "karton";
  version = "0.1-prealpha-unstable-2025-03-02";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "arraybolt";
    repo = "karton";
    rev = "2645686e145e24d2ddd2f5607aba6e955b51bca3";
    hash = "sha256-rqflixikk4ASW5V2Ga1xCXoW2YoIpsXeiL7r7k8dHU8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kirigami
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "/usr/share" "$out/share"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "karton";
    description = "KDE Virtual Machine Manager";
    homepage = "https://invent.kde.org/arraybolt/karton";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
