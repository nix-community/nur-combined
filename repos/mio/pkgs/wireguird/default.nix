{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  gtk3,
  libayatana-appindicator,
  gdk-pixbuf,
  glib,
  gsettings-desktop-schemas,
  wrapGAppsHook3,
  libx11,
  libxrandr,
  libxcursor,
  libxinerama,
  libxi,
  pkg-config,
  makeBinaryWrapper,
  wireguard-tools,
}:
let
  # Build fileb0x separately so we can use it to regenerate static/ab0x.go
  fileb0x = buildGoModule {
    pname = "fileb0x";
    version = "1.1.4";
    src = fetchFromGitHub {
      owner = "UnnoTed";
      repo = "fileb0x";
      rev = "v1.1.4";
      hash = "sha256-/g4Im1R4VKVyl0qN3FYcvKTBHhiIKll4civs987Mo64=";
    };
    vendorHash = "sha256-56A+xFvgJLS8xWodcSzMuN0fB+vXb4Qm8OwbAig2KSM=";

    # Tests fail in sandbox (try to access /dev/tty)
    doCheck = false;
  };

  wireguird-unwrapped = buildGoModule {
    pname = "wireguird-unwrapped";
    version = "1.1.0-unstable-2024-10-31";

    src = fetchFromGitHub {
      owner = "nvlbg";
      repo = "wireguird";
      # https://github.com/UnnoTed/wireguird/pull/61#issuecomment-2449554201 and https://github.com/nvlbg/wireguird/tree/tray_tunnels_submenu
      rev = "6dac3cd8784118f4fe7ea6d544a583c26d589572";
      hash = "sha256-iv0/HSu/6IOVmRZcyCazLdJyyBsu5PyTajLubk0speI=";
    };
    proxyVendor = true;

    vendorHash = "sha256-h58LXLjlriZJEcKn0K0QiPv+Yfbw0zQQBgMQoFL70UY=";

    nativeBuildInputs = [
      pkg-config
      fileb0x
    ];

    buildInputs = [
      gtk3
      libayatana-appindicator
      gdk-pixbuf
      glib
      gsettings-desktop-schemas
      libx11
      libxcursor
      libxrandr
      libxinerama
      libxi
    ];

    postPatch = ''
      # Patch all hardcoded icon paths
      substituteInPlace gui/gui.go \
        --replace-fail 'IconPath    = "/opt/wireguird/Icon/"' \
                       'IconPath    = "${placeholder "out"}/share/wireguird/Icon/"'

      substituteInPlace main.go \
        --replace-fail 'indicator.SetIconThemePath("/opt/wireguird/Icon")' \
                       'indicator.SetIconThemePath("${placeholder "out"}/share/wireguird/Icon")'

      substituteInPlace wireguird.glade \
        --replace-fail '/opt/wireguird/Icon/' \
                       '${placeholder "out"}/share/wireguird/Icon/'
    '';

    preBuild = ''
      # Regenerate the embedded static file with our patched wireguird.glade
      rm -f static/ab0x.go
      fileb0x fileb0x.toml
    '';

    postInstall = ''
      mkdir -p "$out/share/wireguird/Icon"
      cp -r Icon/* "$out/share/wireguird/Icon/"

      # hicolor theme (so Icon=wireguird works from the desktop file)
      for sz in 16x16 32x32 48x48 128x128 256x256; do
        if [ -f "Icon/$sz/wireguard.png" ]; then
          install -Dm644 "Icon/$sz/wireguard.png" \
            "$out/share/icons/hicolor/$sz/apps/wireguird.png"
        fi
      done
      if [ -f Icon/wireguard.svg ]; then
        install -Dm644 Icon/wireguard.svg \
          "$out/share/icons/hicolor/scalable/apps/wireguird.svg"
      fi
    '';

    meta = with lib; {
      description = "Wireguard GUI (unwrapped)";
      homepage = "https://github.com/UnnoTed/wireguird";
      license = licenses.mit;
      platforms = platforms.linux;
      broken = !stdenv.hostPlatform.isLinux;
      mainProgram = "wireguird";
    };
  };

  # Do not put systemd on PATH here: its resolvconf (resolvectl) would beat
  # wireguard-tools' openresolv PATH suffix and break DNS= when openresolv is
  # the backend. programs.wireguird prefixes networking.resolvconf.package.
  wireguardToolPath = "/run/wrappers/bin:${lib.makeBinPath [ wireguard-tools ]}";
in
stdenv.mkDerivation {
  pname = "wireguird";
  inherit (wireguird-unwrapped) version;

  nativeBuildInputs = [
    wrapGAppsHook3
    makeBinaryWrapper
  ];

  buildInputs = [
    gtk3
    gsettings-desktop-schemas
  ];

  unpackPhase = "true";

  buildPhase = ''
    cat <<'EOF' > wrapper.c
    #include <sys/prctl.h>
    #include <unistd.h>
    int main(int argc, char **argv) {
        // The capability wrapper marks the process non-dumpable; the kernel then
        // denies /proc/<pid>/root to xdg-desktop-portal, breaking GTK dark mode.
        // Re-enable dumpable so the portal can read our settings.
        prctl(PR_SET_DUMPABLE, 1, 0, 0, 0);
        execv("${wireguird-unwrapped}/bin/wireguird", argv);
        return 1;
    }
    EOF
    $CC -O2 wrapper.c -o wireguird-dumpable
  '';

  installPhase = ''
    mkdir -p "$out/bin" "$out/share/applications"
    ln -s ${wireguird-unwrapped}/share/icons "$out/share/icons"
    ln -s ${wireguird-unwrapped}/share/wireguird "$out/share/wireguird"

    # Install the C wrapper as the main binary. wrapGAppsHook3 will wrap it
    # automatically in the fixup phase.
    install -Dm755 wireguird-dumpable "$out/bin/wireguird"

    install -Dm644 /dev/stdin "$out/share/applications/wireguird.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=Wireguird
      Comment=WireGuard GUI
      Exec=wireguird
      Terminal=false
      Icon=wireguird
      Categories=Network;Security;
    EOF
  '';

  # Runs as the logged-in user. On NixOS, programs.wireguird installs
  # cap_net_admin wrappers in /run/wrappers/bin (wireguird, wg-quick, wg).
  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${wireguardToolPath})
  '';

  passthru.unwrapped = wireguird-unwrapped;

  meta = wireguird-unwrapped.meta // {
    description = "Wireguard GUI";
    mainProgram = "wireguird";
  };
}
