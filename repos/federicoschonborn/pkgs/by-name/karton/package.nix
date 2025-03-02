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
  version = "0.1-prealpha-unstable-2024-08-07";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "arraybolt";
    repo = "karton";
    rev = "a4dd9a5003be3df112f7e7a3bcda92e48c93abf7";
    hash = "sha256-pxkkmfTgH8jenbtI/ksHraonfS2z/MQ6KsD9N6wUgns=";
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
