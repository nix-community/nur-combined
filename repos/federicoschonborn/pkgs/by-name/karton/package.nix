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
  version = "0.1-prealpha-unstable-2025-05-02";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sitter";
    repo = "karton";
    rev = "b318dca300c7a39a80b4a21d979c45c869ceac76";
    hash = "sha256-j84dxc8yO1wJeizlBmHcVKiCU9BF18AgBXo95b65EWs=";
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
      --replace-fail "virt-viewer" "${lib.getExe' virt-viewer "virt-viewer"}"
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
