{
  autoPatchelfHook,
  glib-networking,
  vulkan-loader,
  webkitgtk_6_0,
  makeWrapper,
  fontconfig,
  libadwaita,
  libplacebo,
  stdenvNoCC,
  libsecret,
  libsoup_3,
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
  libpng,
  curl,
  dpkg,
  glib,
  gtk4,
  sdl3,
  zlib,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "mocktail";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Play Roblox on Linux";
    homepage = "https://github.com/komaruworld/mocktail";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [Prinky];
    platforms = ["x86_64-linux"];
    mainProgram = "mocktail";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  stdenvNoCC.mkDerivation rec {
    inherit pname version src meta;

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
      libpng
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

      runHook postInstall
    '';

    postFixup = ''
      patchelf --replace-needed libplacebo.so.360 libplacebo.so.387 "$out"/lib/x86_64-linux-gnu/mocktail/libvulkan.so || true

      for bin in "$out"/bin/mocktail "$out"/lib/x86_64-linux-gnu/mocktail/mocktail*; do
        [ -f "$bin" ] && [ -x "$bin" ] || continue
        wrapProgram "$bin" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
          --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules"
      done
    '';
  }
