{
  autoPatchelfHook,
  glib-networking,
  vulkan-loader,
  webkitgtk_6_0,
  makeWrapper,
  fontconfig,
  gdk-pixbuf,
  libadwaita,
  libplacebo,
  stdenvNoCC,
  libsoup_3,
  libsecret,
  capstone,
  elfutils,
  gamemode,
  libglvnd,
  utf8proc,
  patchelf,
  sdl3-ttf,
  fetchurl,
  libyaml,
  minizip,
  openssl,
  ffmpeg,
  libpng,
  pango,
  curl,
  dpkg,
  glib,
  gtk4,
  sdl3,
  zlib,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation rec {
    pname = "nightcap";

    inherit version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      patchelf
      dpkg
    ];

    buildInputs = [
      webkitgtk_6_0
      vulkan-loader
      fontconfig
      gdk-pixbuf
      libadwaita
      libplacebo
      libsecret
      libsoup_3
      capstone
      elfutils
      gamemode
      libglvnd
      utf8proc
      sdl3-ttf
      libyaml
      minizip
      openssl
      ffmpeg
      libpng
      pango
      curl
      glib
      gtk4
      sdl3
      zlib
    ];

    sourceRoot = ".";

    autoPatchelfIgnoreMissingDeps = ["libplacebo.so.360"];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r usr/* $out/

      ln -s mocktail $out/bin/nightcap

      substituteInPlace $out/share/applications/io.github.CoderDayton.nightcap.desktop \
        --replace-fail "/usr/bin/mocktail" "$out/bin/mocktail"

      runHook postInstall
    '';

    postFixup = ''
      placebo_so=$(ls ${libplacebo}/lib/libplacebo.so.* 2>/dev/null | head -n1 || true)
      if [ -n "$placebo_so" ]; then
        placebo_soname=$(basename "$placebo_so")
        if [ "$placebo_soname" != "libplacebo.so.360" ]; then
          patchelf --replace-needed libplacebo.so.360 "$placebo_soname" \
            "$out"/lib/x86_64-linux-gnu/mocktail/libvulkan.so || true
        fi
      fi

      for bin in "$out"/bin/mocktail "$out"/lib/x86_64-linux-gnu/mocktail/mocktail*; do
        [ -f "$bin" ] && [ -x "$bin" ] || continue
        wrapProgram "$bin" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
          --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules"
      done
    '';

    meta = {
      description = "Roblox on Linux, tuned for desktop play";
      homepage = "https://github.com/CoderDayton/nightcap";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [Prinky];
      platforms = ["x86_64-linux"];
      mainProgram = "nightcap";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
