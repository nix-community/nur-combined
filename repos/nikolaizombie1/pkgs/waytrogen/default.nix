{
  gtk4,
  glib,
  fetchFromGitHub,
  rustPlatform,
  lib,
  pkg-config,
  wrapGAppsHook4,
  ffmpeg,
  sqlite,
  openssl,
  gsettings-desktop-schemas
}:

rustPlatform.buildRustPackage rec {
  pname = "waytrogen";
  version = "0.5.11";
  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "nikolaizombie1";
    repo = pname;
    rev = "c47cbed6d5ba8307018f37bbc5dbd6b2b165fc06";
    hash = "sha256-YSpvibQ57Tdrd26HagKE/w9B8EU2UbWv9u/lH5teT18=";
  };  

  nativeBuildInputs = [ pkg-config glib wrapGAppsHook4 sqlite ];
  buildInputs = [ glib gtk4 ffmpeg sqlite openssl gsettings-desktop-schemas ];
  env = {
    OPENSSL_NO_VENDOR = 1;
  };
  
  cargoHash = "sha256-S2Oqde3Su5orwKN8gvshKjBf6tswDFSWjan/KoHVJV8=";

  postInstall = ''
  mkdir -p $out/share/glib-2.0/schemas && cp org.Waytrogen.Waytrogen.gschema.xml $out/share/glib-2.0/schemas/
  glib-compile-schemas $out/share/glib-2.0/schemas
  mkdir -p $out/share/locale/en/LC_MESSAGES && msgfmt locales/en/LC_MESSAGES/waytrogen.po -o waytrogen.mo && cp locales/en/LC_MESSAGES/waytrogen.mo $out/share/locale/en/LC_MESSAGES
  mkdir -p $out/share/locale/es/LC_MESSAGES && msgfmt locales/es/LC_MESSAGES/waytrogen.po -o waytrogen.mo && cp locales/es/LC_MESSAGES/waytrogen.mo $out/share/locale/es/LC_MESSAGES
  mkdir -p $out/share/applications && cp waytrogen.desktop $out/share/applications/
  mkdir -p $out/share/icons/hicolor/scalable/apps && cp README-Assets/WaytrogenLogo.svg $out/share/icons/hicolor/scalable/apps/waytrogen.svg
  '';

  meta = {
    description = "A lightning fast wallpaper setter for Wayland.";
    longDescription = "A GUI wallpaper setter for Wayland that is a spiritual successor for the minimalistic wallpaper changer for X11 nitrogen. Written purely in the Rust 🦀 programming language. Supports hyprpaper, swaybg, mpvpaper and swww wallpaper changers.";
    homepage = "https://github.com/nikolaizombie1/waytrogen";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
