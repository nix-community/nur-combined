{
  gsettings-desktop-schemas,
  glib-networking,
  buildFHSEnv,
  stdenvNoCC,
  writeText,
  fetchurl,
  flatpak,
  zstd,
  glib,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  inherit (ver) version;

  pname = "sober";
  src = fetchurl (lib.helper.getSingle ver);

  meta = {
    description = "Play, chat & explore on Roblox";
    homepage = "https://sober.vinegarhq.org/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [Prinky];
    platforms = ["x86_64-linux"];
    mainProgram = "sober";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };

  flatpakInfo = writeText "flatpak-info" ''
    [Application]
    name=org.vinegarhq.Sober
    runtime=org.gnome.Platform/x86_64/51

    [Context]
    shared=ipc;network
    sockets=wayland;fallback-x11;pulseaudio
    devices=dri
    features=devel
    filesystems=xdg-run/app/com.discordapp.Discord:create;xdg-run/discord-ipc-0

    [Instance]
    instance-id=sober
    arch=x86_64
    flatpak-version=${flatpak.version}
    branch=stable
    sandbox=true
  '';

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version src;

    nativeBuildInputs = [zstd];

    sourceRoot = ".";
    dontBuild = true;
    dontStrip = true;
    dontFixup = true;

    unpackPhase = ''
      runHook preUnpack
      tar --zstd -xf "$src"
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      dir=$(find . -maxdepth 1 -type d -name "sober-binaries-*" | head -n1)
      if [ -z "$dir" ]; then
        echo "error: sober binaries directory not found in $PWD" >&2
        exit 1
      fi

      install -Dm755 "$dir/sober" "$out/bin/sober"
      install -Dm755 "$dir/sober_services" "$out/bin/sober_services"
      install -Dm755 "$dir/libloader.so" "$out/bin/libloader.so"
      install -Dm755 "$dir/libbadcpu.so" "$out/bin/libbadcpu.so"

      install -Dm644 "$dir/org.vinegarhq.Sober.desktop" "$out/share/applications/org.vinegarhq.Sober.desktop"
      install -Dm644 "$dir/org.vinegarhq.Sober.metainfo.xml" "$out/share/metainfo/org.vinegarhq.Sober.metainfo.xml"
      install -Dm644 "$dir/sober.svg" "$out/share/icons/hicolor/scalable/apps/org.vinegarhq.Sober.svg"
      install -Dm644 "$dir/notice.txt" "$out/share/licenses/org.vinegarhq.Sober/EULA.txt"
      install -Dm644 "$dir/privacy.txt" "$out/share/licenses/org.vinegarhq.Sober/PRIVACY.txt"

      runHook postInstall
    '';

    inherit meta;
  };
in
  buildFHSEnv {
    inherit pname version;

    targetPkgs = pkgs:
      with pkgs; [
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gsettings-desktop-schemas
        gst_all_1.gstreamer
        glib-networking
        webkitgtk_6_0
        vulkan-loader
        libpulseaudio
        fontconfig
        libadwaita
        noto-fonts
        unwrapped
        libsoup_3
        libsecret
        freetype
        libglvnd
        alsa-lib
        openssl
        libxml2
        curl
        zlib
        glib
        dbus
        gtk4
        mesa
        nss
      ];

    profile = ''
      export container=flatpak
      export XDG_DATA_DIRS="${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:$XDG_DATA_DIRS"
      export GIO_EXTRA_MODULES="${glib.out}/lib/gio/modules"
      export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules"
    '';

    extraBwrapArgs = [
      "--ro-bind"
      "${flatpakInfo}"
      "/.flatpak-info"
    ];

    runScript = "${unwrapped}/bin/sober";

    extraInstallCommands = ''
      mkdir -p "$out/share"
      cp -r "${unwrapped}/share/"* "$out/share/"
    '';

    inherit meta;
  }
