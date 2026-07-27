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
      rev = "df1a03d7d838026f3c70ca18b1d8867f605ed51c";
      hash = "sha256-uXNpJv687gJMITVYsfuGOywoElKxEcZMRd6HYVHFu24=";
    };
    nativeBuildInputs = [ appstream ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/app-info/{icons/nixos,xmls}
      cp appstream/nixos-unstable/Components-*.xml.gz $out/share/app-info/xmls/nixos_x86_64_linux.yml.gz
      for tarball in appstream/nixos-unstable/icons-*.tar.gz; do
        size=$(basename "$tarball" .tar.gz | sed 's/icons-//')
        mkdir -p $out/share/app-info/icons/nixos/$size
        tar -xzf "$tarball" -C $out/share/app-info/icons/nixos/$size/
      done
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
      "nix-data-0.0.3" = "sha256-kLcAtvZPa1VKHmMJR3xiX94lkkmfUFvzn/pnw6r5w4I=";
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
    cp ${./Cargo.lock} Cargo.lock
    substituteInPlace ./Cargo.toml \
        --replace-fail 'sqlx = { version = "0.6"' 'sqlx = { version = "0.7"'
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
