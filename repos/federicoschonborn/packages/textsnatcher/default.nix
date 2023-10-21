{ lib
, stdenv
, fetchFromGitHub
, desktop-file-utils
, libhandy
, libportal
, meson
, ninja
, pantheon
, pkg-config
, tesseract
, vala
, wrapGAppsHook
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textsnatcher";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "RajSolai";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-phqtPjwKB5BoCpL+cMeHvRLL76ZxQ5T74cpAsgN+/JM=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    libhandy
    libportal
    pantheon.granite
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ tesseract ]}
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "com.github.rajsolai.textsnatcher";
    description = "Perform OCR operations in seconds on the Linux desktop";
    homepage = "https://github.com/RajSolai/TextSnatcher";
    changelog = "https://github.com/RajSolai/TextSnatcher/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
