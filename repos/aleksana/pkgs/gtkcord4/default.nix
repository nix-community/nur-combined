{
  stdenv,
  lib,
  fetchFromGitHub,
  buildGoModule,
  wrapGAppsHook,
  pkg-config,
  glib,
  graphene,
  cairo,
  gobject-introspection,
  pango,
  gdk-pixbuf,
  gtk4,
  gsettings-desktop-schemas,
  libcanberra-gtk3,
}:

buildGoModule rec {
  pname = "gtkcord4";
  version = "0.0.6";
  
  src = fetchFromGitHub {
    owner = "diamondburned";
    repo = "gtkcord4";
    rev = "v${version}";
    hash = "sha256-uEG1pAHMQT+C/E5rKByflvL0NNkC8SeSPMAXanzvhE4=";
  };
  
  vendorHash = "sha256-QZSjSk1xu5ZcrNEra5TxnUVvlQWb5/h31fm5Nc7WMoI=";
  
  nativeBuildInputs = [ wrapGAppsHook pkg-config glib ];
  
  buildInputs = [
    glib
    graphene
    cairo
    gobject-introspection
    pango
    gdk-pixbuf
    gtk4
    gsettings-desktop-schemas
    libcanberra-gtk3
  ];
  
  # TODO: rename .nix to nix in next ver
  postInstall = ''
    install -Dm755 $src/internal/icons/png/logo.png $out/share/icons/hicolor/256x256/apps/gtkcord4.png
    install -Dm755 $src/.nix/com.github.diamondburned.gtkcord4.desktop $out/share/applications/com.github.diamondburned.gtkcord4.desktop
  '';
  
  meta = with lib; {
    description = "GTK4 Discord client in Go, attempt #4. ";
    homepage = "https://github.com/diamondburned/${pname}";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
