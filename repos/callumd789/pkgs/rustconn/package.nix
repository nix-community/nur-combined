{
  lib,
  rustPlatform,
  fetchFromGitHub,
  gettext,
  pkg-config,
  wrapGAppsHook4,
  alsa-lib,
  glib-networking,
  gtk4,
  libadwaita,
  openssl,
  vte-gtk4,
  webkitgtk_6_0,
  zstd,
  nix-update-script,
}:

let
  # Added to the GUI's default features, as upstream's Flatpak and OBS builds
  # do. Each needs at least that version of the library, which nixos-26.05 and
  # nixpkgs-unstable both have. vte-0-84 enables the Command monitoring mode.
  guiFeatures = [
    "adw-1-8"
    "gtk-4-22"
    "vte-0-84"
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustconn";
  version = "0.24.9";

  src = fetchFromGitHub {
    owner = "totoshko88";
    repo = "RustConn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hq/Yj1A2M+j84NfXVjxNb777HlPRCqjC2/FvtGkFw7Q=";
  };

  cargoHash = "sha256-DaBahUEHe/HkWrQRCFLb9wEalHw25VMA9DHsb0kzbFE=";

  # Translations are looked up in a few places that don't exist here (the build
  # directory from build.rs among them) before falling back to
  # /usr/share/locale.
  postPatch = ''
    substituteInPlace rustconn/src/i18n.rs \
      --replace-fail '"/usr/share/locale".to_string()' "\"$out/share/locale\".to_string()"
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    alsa-lib
    glib-networking
    gtk4
    libadwaita
    openssl
    vte-gtk4
    webkitgtk_6_0
    # Newer nixpkgs' cargoSetupHook makes zstd-sys link it rather than build
    # its own copy.
    zstd
  ];

  # Keeps aws-lc-sys building its own AWS-LC, as upstream's packages and older
  # nixpkgs do. Newer nixpkgs' cargoSetupHook sets AWS_LC_SYS_USE_SYSTEM=1 to
  # link nixpkgs' aws-lc instead, but in older nixpkgs (nixos-26.05 included)
  # that exports the same unprefixed symbols as OpenSSL's libcrypto, which this
  # links too. The hook runs in preConfigure, so this has to come later.
  preBuild = ''
    export AWS_LC_SYS_USE_SYSTEM=0
  '';

  # Two cargo invocations, as in upstream's own packages: the CLI needs its
  # `full` feature for the connect, secret and SFTP commands, and building it
  # alone keeps the GUI's rustconn-core features out of it.
  buildPhase = ''
    runHook preBuild

    cargo build -j $NIX_BUILD_CORES --offline --profile release \
      --package rustconn --features ${lib.concatStringsSep "," guiFeatures}
    cargo build -j $NIX_BUILD_CORES --offline --profile release \
      --package rustconn-cli --features full

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin target/release/rustconn target/release/rustconn-cli

    install -Dm644 -t $out/share/applications rustconn/assets/io.github.totoshko88.RustConn.desktop
    install -Dm644 -t $out/share/metainfo rustconn/assets/io.github.totoshko88.RustConn.metainfo.xml
    install -Dm644 -t $out/share/mime/packages rustconn/assets/io.github.totoshko88.RustConn-{rdp,vv}.xml
    # The app icon, and the tray and filter icons the GUI looks up by name.
    cp -r rustconn/assets/icons $out/share/icons

    for po in po/*.po; do
      lang=$(basename "$po" .po)
      install -d $out/share/locale/$lang/LC_MESSAGES
      msgfmt -o $out/share/locale/$lang/LC_MESSAGES/rustconn.mo "$po"
    done

    runHook postInstall
  '';

  # Upstream's CI runs the test suite and none of its packages do. The default
  # checkPhase wouldn't match the builds above either: it tests one feature set
  # for the whole workspace, and compiles most of it again to do so.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK4/libadwaita connection manager for SSH, RDP, VNC, SPICE, Telnet, Serial and Kubernetes";
    homepage = "https://github.com/totoshko88/RustConn";
    changelog = "https://github.com/totoshko88/RustConn/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    mainProgram = "rustconn";
    platforms = lib.platforms.linux;
  };
})
