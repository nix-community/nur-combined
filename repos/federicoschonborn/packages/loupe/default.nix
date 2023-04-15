{
  lib,
  stdenv,
  fetchurl,
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
  version = "44.1";

  src = fetchurl {
    url = "mirror://gnome/sources/loupe/${lib.versions.major version}/loupe-${version}.tar.xz";
    hash = "sha256-mPu2K4rcOXjzySoaDouutYVdhmdhJz463zfBP7iJ06M=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "";
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
