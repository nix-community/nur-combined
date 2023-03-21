{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  itstool,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  libgweather,
  libheif,
  libxml2,
}:
stdenv.mkDerivation rec {
  pname = "loupe";
  version = "unstable-2023-03-18";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "Incubator";
    repo = pname;
    rev = "0e24f347e6c734acc7f0d542ab79b28e6b6a24cb";
    hash = "sha256-uAY192BsYqDb1f/e2rE9KWKDskag0Bmpv3SP/5d9TVE=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-tUi+y6raAhfG1bvUuSR/MRIax3OhExOBxn8gElLBRfI=";
  };

  nativeBuildInputs =
    [
      desktop-file-utils
      itstool
      meson
      ninja
      pkg-config
      wrapGAppsHook4
    ]
    ++ (with rustPlatform; [
      cargoSetupHook
      rust.cargo
      rust.rustc
    ]);

  buildInputs = [
    gtk4
    libadwaita
    libgweather
    libheif
    libxml2
  ];

  meta = with lib; {
    description = "A simple image viewer application written with GTK4 and Rust";
    homepage = "https://gitlab.gnome.org/Incubator/loupe/";
    license = licenses.gpl3Only;
  };
}
