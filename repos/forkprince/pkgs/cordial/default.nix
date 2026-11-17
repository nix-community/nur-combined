{
  autoPatchelfHook,
  glib-networking,
  vulkan-loader,
  webkitgtk_6_0,
  libxkbcommon,
  makeWrapper,
  fontconfig,
  gdk-pixbuf,
  libadwaita,
  stdenvNoCC,
  libsoup_3,
  graphene,
  libglvnd,
  pipewire,
  fetchurl,
  wayland,
  cairo,
  pango,
  glib,
  gtk4,
  dpkg,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "cordial";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Run Roblox's Android client natively on Linux";
    homepage = "https://github.com/luohoa97/cordial";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux;
    mainProgram = "cordial";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  stdenvNoCC.mkDerivation rec {
    inherit pname version src meta;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      dpkg
    ];

    buildInputs = [
      webkitgtk_6_0
      vulkan-loader
      libxkbcommon
      libadwaita
      gdk-pixbuf
      fontconfig
      libsoup_3
      graphene
      libglvnd
      pipewire
      wayland
      pango
      cairo
      gtk4
      glib
    ];

    sourceRoot = ".";

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r usr/* $out/

      substituteInPlace $out/share/applications/io.github.luohoa97.Cordial.desktop \
        --replace-fail "Exec=cordial-shell" "Exec=$out/bin/cordial-shell"

      runHook postInstall
    '';

    postFixup = ''
      for bin in "$out"/bin/cordial-shell "$out"/bin/cordial-run; do
        [ -f "$bin" ] && [ -x "$bin" ] || continue
        wrapProgram "$bin" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
          --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules"
      done
    '';
  }
