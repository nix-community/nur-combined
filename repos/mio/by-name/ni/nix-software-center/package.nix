{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  appstream-glib,
  polkit,
  gettext,
  desktop-file-utils,
  meson,
  ninja,
  pkg-config,
  git,
  wrapGAppsHook4,
  cargo,
  rustc,
  gdk-pixbuf,
  glib,
  gtk4,
  gtksourceview5,
  libadwaita,
  libxml2,
  openssl,
  wayland,
  adwaita-icon-theme,
  gnome-console,
  gtk3,
  sqlite,
  appstream,
}:

let
  nixos-appstream-data = stdenv.mkDerivation {
    pname = "nixos-appstream-data";
    version = "unstable-2023-08-21";
    src = fetchFromGitHub {
      owner = "vlinkz";
      repo = "nixos-appstream-data";
      rev = "66b3399e6d81017c10265611a151d1109ff1af1b";
      hash = "sha256-oiEZD4sMpb2djxReg99GUo0RHWAehxSyQBbiz8Z4DJk=";
    };
    nativeBuildInputs = [ appstream ];
    installPhase = ''
      runHook preInstall
      bash ./build.sh all
      mkdir -p $out/share/app-info/{icons/nixos,xmls}
      cp dest/*.gz $out/share/app-info/xmls/
      cp -r dest/icons/64x64 $out/share/app-info/icons/nixos/
      cp -r dest/icons/128x128 $out/share/app-info/icons/nixos/
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation rec {
  pname = "nix-software-center";
  version = "0.1.2-unstable-2023-11-20";

  src = fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-software-center";
    rev = "181c1c61eab79130879257550dba0b36bd6bb8c9";
    hash = "sha256-hnApcv/55630/y7MPU7zgWYSStxj9IpnEfgxl/qpLj0=";
  };

  # We maintain and bump this Cargo.lock ourselves since upstream doesn't always keep it perfectly up to date
  # or to fix vulnerabilities. Run `cargo update` in the upstream source to update it, and adjust `outputHashes`.
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "nix-data-0.0.2" = "sha256-yts2bkp9cn4SuYPYjgTNbOwTtpFxps3TU8zmS/ftN/Q=";
    };
  };

  nativeBuildInputs = [
    appstream-glib
    polkit
    gettext
    desktop-file-utils
    meson
    ninja
    pkg-config
    git
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gtk4
    gtksourceview5
    libadwaita
    libxml2
    openssl
    wayland
    adwaita-icon-theme
    desktop-file-utils
    nixos-appstream-data
  ];

  patchPhase = ''
    substituteInPlace ./src/lib.rs \
        --replace-fail "/usr/share/app-info" "${nixos-appstream-data}/share/app-info"
  '';

  postInstall = ''
    wrapProgram $out/bin/nix-software-center --prefix PATH : '${
      lib.makeBinPath [
        gnome-console
        gtk3 # provides gtk-launch
        sqlite
      ]
    }'
  '';

  meta = with lib; {
    description = "A Software Center for NixOS";
    homepage = "https://github.com/snowfallorg/nix-software-center";
    license = licenses.mit;
    mainProgram = "nix-software-center";
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
