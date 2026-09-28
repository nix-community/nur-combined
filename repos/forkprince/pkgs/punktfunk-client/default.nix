{
  autoPatchelfHook,
  wrapGAppsHook4,
  vulkan-loader,
  stdenvNoCC,
  libadwaita,
  fontconfig,
  fetchurl,
  freetype,
  patchelf,
  pipewire,
  wayland,
  python3,
  stdenv,
  cairo,
  libGL,
  libva,
  _7zz,
  dpkg,
  gtk4,
  glib,
  sdl3,
  opus,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "punktfunk-client";
  src = fetchurl (lib.helper.getPlatform stdenv.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Low-latency desktop and game streaming client";
    homepage = "https://docs.punktfunk.unom.io";
    license = with lib.licenses; [asl20 mit];
    maintainers = with lib.maintainers; [Prinky];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
in
  if stdenv.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      pname = "punktfunk";
      inherit version src meta;

      nativeBuildInputs = [_7zz];
    })
  else
    stdenv.mkDerivation {
      inherit pname version src;
      meta =
        meta
        // {
          mainProgram = "punktfunk-client";
        };

      sourceRoot = ".";

      nativeBuildInputs = [
        autoPatchelfHook
        wrapGAppsHook4
        patchelf
        python3
        dpkg
      ];

      buildInputs = [
        stdenv.cc.cc.lib
        vulkan-loader
        fontconfig
        libadwaita
        freetype
        pipewire
        wayland
        cairo
        libva
        libGL
        glib
        gtk4
        opus
        sdl3
      ];

      dontConfigure = true;
      dontBuild = true;

      unpackPhase = ''
        runHook preUnpack
        dpkg-deb -x $src .
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        install -Dm755 usr/bin/{punktfunk,punktfunk-client,punktfunk-session} -t $out/bin

        install -Dm644 usr/share/applications/io.unom.Punktfunk.{desktop,Console.desktop} -t $out/share/applications
        install -Dm644 usr/share/icons/hicolor/scalable/apps/io.unom.Punktfunk.svg -t $out/share/icons/hicolor/scalable/apps
        install -Dm644 usr/lib/udev/rules.d/70-punktfunk-client.rules -t $out/lib/udev/rules.d

        runHook postInstall
      '';

      # glibc 2.43 introduced new symbol versions for several libm symbols.
      # nixpkgs uses an older glibc that provides these symbols under their
      # previous versions, so remove the newer version requirements.
      #
      # The symbols alone aren't enough: ld.so also checks .gnu.version_r
      # at load time, so the GLIBC_2.43 version entry must be updated too.
      #
      # wrapGAppsHook4 moves binaries to .<name>-wrapped during fixupOutput,
      # before this hook runs, hence the dotfile glob.
      postFixup = ''
        glibcVersion="${stdenv.cc.libc.version}"

        for elf in "$out"/bin/* "$out"/bin/.[!.]*; do
          [ -f "$elf" ] || continue
          [ "$(head -c 4 "$elf")" = $'\x7fELF' ] || continue

          for node in $(readelf --version-info "$elf" | grep -o 'GLIBC_[0-9.]*' | sort -u | awk -v current="$glibcVersion" '
            function version(s) { split(s, part, "."); return part[1] * 1000000 + part[2] }
            { sub(/^GLIBC_/, ""); if (version($0) > version(current)) print }
          '); do
            for symbol in $(readelf -sW "$elf" | awk -v node="GLIBC_$node" '
              $8 ~ ("@" node "$") { sub(/@.*/, "", $8); print $8 }
            ' | sort -u); do
              echo "$elf: $symbol@$node is newer than glibc $glibcVersion, unversioning"
              patchelf --clear-symbol-version "$symbol" "$elf"
            done
          done

          python3 ${./fix-glibc-versions.py} "$elf" "$glibcVersion"
        done
      '';
    }
