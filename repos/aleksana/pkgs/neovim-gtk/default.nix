{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  wrapGAppsHook,
  pkg-config,
  gtk4,
  glib,
  pango,
  gdk-pixbuf,
  vte-gtk4,
}:

rustPlatform.buildRustPackage rec {
  pname = "neovim-gtk";
  version = "1.0.4";
  
  src = fetchFromGitHub {
    owner = "Lyude";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-inva7pYwOw3bXvFeKZ4aKSQ65iCat5HxM+NME8jN4/I=";
  };
  
  cargoHash = "sha256-9eZwCOP4xQtFOieqVRBAdXZrXmzdnae6PexGJ/eCyYc=";
  
  nativeBuildInputs = [ wrapGAppsHook pkg-config glib gdk-pixbuf ];
  
  buildInputs = [ gtk4 pango vte-gtk4 ];
  
  postInstall = ''
    cd $src
    make DESTDIR=/ PREFIX=$out install-resources
  '';
  
  meta = with lib; {
    description = "Gtk ui for neovim (Rewritted in gtk4). ";
    homepage = "https://github.com/Lyude/${pname}";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
