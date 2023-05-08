{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  cairo,
  desktop-file-utils,
  gdk-pixbuf,
  glib,
  gtk4,
  lcms,
  libadwaita,
  libgweather,
  libheif,
  pango,
  darwin,
}:
stdenv.mkDerivation rec {
  pname = "loupe";
  version = "44.2";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "Incubator";
    repo = "loupe";
    rev = version;
    hash = "sha256-0No8D2G/PSr8EWXJiBmBt672J340CJUzjdvF5fQZwes=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "librsvg-2.56.0" = "sha256-4poP7xsoylmnKaUWuJ0tnlgEMpw9iJrM3dvt4IaFi7w=";
    };
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
  ];

  buildInputs =
    [
      cairo
      gdk-pixbuf
      glib
      gtk4
      lcms
      libadwaita
      libgweather
      libheif
      pango
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
    ];

  meta = with lib; {
    description = "View images";
    homepage = "https://gitlab.gnome.org/Incubator/loupe";
    changelog = "https://gitlab.gnome.org/Incubator/loupe/-/blob/${src.rev}/NEWS";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
  };
}
