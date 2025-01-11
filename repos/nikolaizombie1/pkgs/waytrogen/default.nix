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
  openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "waytrogen";
  version = "0.5.3";
  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "nikolaizombie1";
    repo = pname;
    rev = version;
    hash = "sha256-uigBtmFPVPoYXNQPwFOAxwOFUApk05+zIKH9szLCG74=";
  };

  

  nativeBuildInputs = [ pkg-config glib wrapGAppsHook4 sqlite ];
  buildInputs = [ glib gtk4 ffmpeg sqlite openssl ];
  env = {
    OPENSSL_NO_VENDOR = 1;
  };
  
  cargoHash = "sha256-hTPMLruXf5SIuaI4ij7WncRZd4w10DHe/z+HnfKmba0=";

  meta = {
    description = "A lightning fast wallpaper setter for Wayland.";
    longDescription = "A GUI wallpaper setter for Wayland that is a spiritual successor for the minimalistic wallpaper changer for X11 nitrogen. Written purely in the Rust 🦀 programming language. Supports hyprpaper, swaybg, mpvpaper and swww wallpaper changers.";
    homepage = "https://github.com/nikolaizombie1/waytrogen";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
