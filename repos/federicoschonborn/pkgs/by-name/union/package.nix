{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ninja,
  kdePackages,
  cxx-rust-cssparser,
  rapidyaml,
  nix-update-script,
  withCSSInput ? true,
}:

stdenv.mkDerivation (_: {
  pname = "union";
  version = "0-unstable-2025-06-23";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "union";
    rev = "3d564ba83c61474b0e973a60b8c507e039286c33";
    hash = "sha256-pDu9tcId+26yCRosbJyG9yMnJraK8fLRIJ1UTurClCk=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    kdePackages.karchive
    kdePackages.kcolorscheme
    kdePackages.kconfig
    kdePackages.libplasma
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtsvg
    rapidyaml
  ] ++ lib.optional withCSSInput cxx-rust-cssparser;

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeBool "WITH_CSS_INPUT" withCSSInput)
  ];

  postPatch = ''
    # Added on ECM 6.11.0
    substituteInPlace CMakeLists.txt --replace-fail "include(ECMGenerateQDoc" "#include(ECMGenerateQDoc"
    substituteInPlace src/CMakeLists.txt --replace-fail "ecm_generate_qdoc" "#ecm_generate_qdoc"
  '';

  dontWrapQtApps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A Qt style supporting both QtQuick and QtWidgets";
    homepage = "https://invent.kde.org/plasma/union";
    license = with lib.licenses; [
      bsd2
      cc0
      gpl2Only
      gpl3Only
      lgpl21Only
      lgpl3Only
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
