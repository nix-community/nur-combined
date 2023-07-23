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

  meta = with lib; {
    description = "Perform OCR operations in seconds on the Linux desktop";
    mainProgram = "com.github.rajsolai.textsnatcher";
    homepage = "https://github.com/RajSolai/TextSnatcher";
    changelog = "https://github.com/RajSolai/TextSnatcher/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    broken = stdenv.isDarwin;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
