{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libx11,
  libxrandr,
  mpv,
}:

rustPlatform.buildRustPackage rec {
  pname = "ff00-vwm";
  version = "0.1.0-alpha.1";

  src = fetchFromGitHub {
    owner = "crimsonvariable";
    repo = "ff00-vwm";
    tag = "v${version}";
    hash = "sha256-QnXMH0qgTaU/tdBJn1qm6ErPjGeYB5AbjMj9mQjBhjc=";
  };

  cargoHash = "sha256-D5dQyBxjdJzUu99xwt3QaFlOmnOwvU9JA0Yd0ZQkElA=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libx11
    libxrandr
  ];

  postInstall = ''
    install -Dm644 data/com.crimsonvariable.FF00Vwm.desktop \
      "$out/share/applications/com.crimsonvariable.FF00Vwm.desktop"
    install -Dm644 data/icons/ff00-vwm.svg \
      "$out/share/icons/hicolor/scalable/apps/ff00-vwm.svg"
    install -Dm644 README.md CHANGELOG.md LICENSE THIRD_PARTY_NOTICES.md \
      THIRD_PARTY_LICENSES.txt TYPEFACE_CREDITS.md \
      -t "$out/share/doc/ff00-vwm"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ mpv ]}
    )
  '';

  meta = {
    description = "Per-monitor video wallpaper manager for Linux X11";
    homepage = "https://crimsonvariable.com/projects/ff00-vwm/";
    changelog = "https://github.com/crimsonvariable/ff00-vwm/blob/v${version}/CHANGELOG.md";
    downloadPage = "https://github.com/crimsonvariable/ff00-vwm/releases";
    license = lib.licenses.agpl3Plus;
    mainProgram = "ff00-vwm";
    platforms = [ "x86_64-linux" ];
  };
}
