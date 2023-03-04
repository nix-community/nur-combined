{
  stdenv,
  fetchFromGitLab,
  rustPlatform,
  meson,
  desktop-file-utils,
  itstool,
  ninja,
  pkg-config,
  gtk4,
  libadwaita,
  wrapGAppsHook,
}:
stdenv.mkDerivation rec {
  pname = "loupe";
  version = "unstable-2023-03-01";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "Incubator";
    repo = pname;
    rev = "038d9cb5c07b7f8ee5082e72a95bf5feb06aa807";
    hash = "sha256-YeoV8BlQwWt7KNke/KB/ub2CV1fITdiGl6PeBfo/xT4=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-7Ag0D3gl45PNe2czoRvsXaRjI/JsY0EEZfVfL/zlra0=";
  };

  nativeBuildInputs =
    [
      desktop-file-utils
      itstool
      meson
      ninja
      pkg-config
      wrapGAppsHook
    ]
    ++ (with rustPlatform; [
      cargoSetupHook
      rust.cargo
      rust.rustc
    ]);

  buildInputs = [
    gtk4
    libadwaita
  ];
}
