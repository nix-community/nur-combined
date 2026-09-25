{
  lib,
  stdenv,
  ostree,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  pkgs,
}:

let
  # Upstream releases are named e.g. `2.0~publicbeta66`; `~` is not a legal
  # character in a Nix store path, hence the substitution.
  version = "2.0-publicbeta66";
  pname = "threema-desktop";

  # Threema only ships the desktop beta for Linux as a Flatpak, self-hosting the
  # OSTree repository it is installed from. Pull the application commit and check
  # it out; the libraries it would otherwise inherit from org.freedesktop.Platform
  # are provided by nixpkgs below.
  flatpakRepo = "https://releases.threema.ch/flatpak/threema-desktop/";
  flatpakRef = "app/ch.threema.threema-desktop/x86_64/master";
  flatpakCommit = "83b2f4278cf5cca19ef57b2d399363f0af1fd45d990fac2406eb1a9f302f19f9";

  src = stdenv.mkDerivation {
    pname = "${pname}-flatpak";
    inherit version;

    nativeBuildInputs = [
      ostree
      pkgs.cacert
    ];

    # OSTree is content-addressed and checkouts are reproducible, so pinning the
    # resulting tree keeps the build verifiable and offline-capable.
    outputHashMode = "recursive";
    outputHash = "sha256-FVHbQky84FrAQcRjlZEIEsFmCHOx5o60mJv+T5u230Q=";

    dontUnpack = true;
    buildCommand = ''
      runHook preBuild

      # The sandbox has no system trust store; ostree talks to the mirror through
      # libsoup/glib-networking, which honours G_TLS_CA_FILE.
      export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      export SSL_CERT_FILE="$NIX_SSL_CERT_FILE"
      export G_TLS_CA_FILE="$NIX_SSL_CERT_FILE"

      repo="$TMPDIR/ostree-repo"
      ostree --repo="$repo" init --mode=archive-z2
      ostree --repo="$repo" remote add --no-gpg-verify threema "${flatpakRepo}"
      ostree --repo="$repo" pull --depth=-1 threema "${flatpakRef}"

      commit=$(ostree --repo="$repo" rev-parse "threema:${flatpakRef}")
      if [ "$commit" != "${flatpakCommit}" ]; then
        echo "error: expected Threema flatpak commit ${flatpakCommit}, got $commit" >&2
        exit 1
      fi

      ostree --repo="$repo" checkout -U "threema:${flatpakRef}" "$out"

      runHook postBuild
    '';
  };

  desktopItem = makeDesktopItem {
    name = "threema-desktop";
    desktopName = "Threema Beta";
    comment = "Privacy-focused end-to-end encrypted messenger";
    exec = "threema-desktop %U";
    icon = "ch.threema.threema-desktop";
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    startupWMClass = "Threema Beta";
    terminal = false;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libpulseaudio
    mesa
    nspr
    nss
    pango
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXt
    xorg.libXtst
    xorg.libxcb
    systemdMinimal # libudev
  ];

  dontConfigure = true;
  dontBuild = true;

  desktopItems = [ desktopItem ];

  installPhase = ''
    runHook preInstall

    # Electron resolves `resources/` relative to the executable, so keep the
    # upstream directory layout (`/app/main` inside the Flatpak) as-is.
    mkdir -p $out/lib/threema-desktop
    cp -r files/main/. $out/lib/threema-desktop/

    mkdir -p $out/share
    cp -r files/share/icons $out/share/
    install -Dm644 export/share/metainfo/ch.threema.threema-desktop.metainfo.xml \
      $out/share/metainfo/ch.threema.threema-desktop.metainfo.xml

    makeWrapper $out/lib/threema-desktop/ThreemaDesktop $out/bin/threema-desktop \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          pkgs.alsa-lib
          pkgs.libGL
          pkgs.libpulseaudio
          pkgs.libsecret
          pkgs.vulkan-loader
        ]
      }"

    runHook postInstall
  '';

  meta = {
    description = "Threema desktop client for the privacy-focused, end-to-end encrypted messenger";
    homepage = "https://threema.com/en/download/threema-private/desktop-beta";
    downloadPage = "https://threema.com/en/download/threema-private/desktop-beta";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "threema-desktop";
  };
}
