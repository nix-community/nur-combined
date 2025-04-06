{
  lib,
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  ninja,
  pkg-config,
  python3,
  libvirt,
  virt-manager,
  virt-viewer,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "karton";
  version = "0.1-prealpha-unstable-2025-03-31";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sitter";
    repo = "karton";
    rev = "8a983c95391009fe681704ebaf29142cef795733";
    hash = "sha256-qNv1Z69NTJJbwzDIqLgLXJoOSjgSPVyjtBRr8OFPtZ0=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    libvirt
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kirigami
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "/usr/share" "$out/share" \
      --replace-fail "ecm_find_qmlmodule(org.kde.kirigami REQUIRED)" "ecm_find_qmlmodule(org.kde.kirigami)"

    substituteInPlace src/karton.cpp \
      --replace-fail "virt-install" "${lib.getExe' virt-manager "virt-install"}" \
      --replace-fail "virt-viewer" "${lib.getExe virt-viewer}"
  '';

  strictDeps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "karton";
    description = "KDE Virtual Machine Manager";
    homepage = "https://invent.kde.org/sitter/karton";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
