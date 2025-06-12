{
  lib,
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  ninja,
  pkg-config,
  python3,
  libosinfo,
  libvirt,
  virt-manager,
  virt-viewer,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "karton";
  version = "0.1-prealpha-unstable-2025-06-12";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sitter";
    repo = "karton";
    rev = "fdfaef87d975786cdbd6ddf3bdefbb40f6179002";
    hash = "sha256-ZHmesXc5mJvqHGQdOx2QEmGih1b46ZfQkmn/QY8+RpI=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    libosinfo
    libvirt
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kirigami
    kdePackages.qtbase
    kdePackages.qtdeclarative
  ] ++ lib.optional stdenv.hostPlatform.isLinux kdePackages.qtwayland;

  strictDeps = true;

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "/usr/share" "$out/share" \
      --replace-fail "ecm_find_qmlmodule(org.kde.kirigami REQUIRED)" "ecm_find_qmlmodule(org.kde.kirigami)"

    substituteInPlace src/karton.cpp \
      --replace-fail "virt-install" "${lib.getExe' virt-manager "virt-install"}" \
      --replace-fail "virt-viewer" "${lib.getExe' virt-viewer "virt-viewer"}"
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
    homepage = "https://invent.kde.org/sitter/karton";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
