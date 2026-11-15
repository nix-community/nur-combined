{ lib, pkgs }:
let
  src = pkgs.callPackage ./source.nix { };
  version = "0.13.7-unstable-2026-11-15";
  runtime = pkgs.callPackage ./runtime.nix { inherit src version; };
  launcher = pkgs.callPackage ./launcher.nix { inherit src version; };
  shaders = pkgs.callPackage ./shaders.nix { inherit src version; };
  python = pkgs.python3.withPackages (p: [
    p.capstone
    p.lz4
    p.pillow
  ]);
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "recompia";
  inherit src version;
  postPatch = ''
    # The executable produced later on the player's machine also needs a Nix loader.
    substituteInPlace game-build/release_b/pkp_build.py \
      --replace-fail "'-Wl,--strip-debug']" "'-Wl,--strip-debug', '-Wl,--dynamic-linker,${pkgs.stdenv.cc.bintools.dynamicLinker}', '-Wl,-rpath,${
        lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.glibc
        ]
      }']"
  '';
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    dest=$out/share/recompia
    mkdir -p $dest/tools/build/sdk/fonts $dest/tools/shaders $dest/tools/linux/python/bin $dest/tools/linux/zig $dest/assets $out/bin
    cp ${runtime}/lib/libpkp_rt.so $dest/
    cp ${runtime}/lib/libpkp_rt.so $dest/tools/build/sdk/
    cp game-build/release_b/{pkp_build.py,dump_hashes.json,fetch_dlss.py} $dest/tools/build/
    cp -r recomp $dest/tools/build/
    (cd $dest/tools/build/recomp && find . -type f | sed 's|^./||' | LC_ALL=C sort) > $dest/tools/build/recomp.files
    cp game-build/src/{pkp_stub.cpp,pkp_rt_api.h} $dest/tools/build/sdk/
    cp runtime/assets/fonts/DejaVuSans.ttf $dest/tools/build/sdk/fonts/
    python3 tools/kbm_icons.py --out $dest/tools/build/sdk/kbm_icons
    cp -r runtime/assets/prompts $dest/assets/
    cp tools/shaders/ampere/extract_corpus.py $dest/tools/shaders/
    mkdir -p $dest/tools/harness
    cp -rs ${shaders}/lib/recompia-shaders/. $dest/tools/harness/
    ln -sfn ${shaders}/bin/spirv_harness $dest/tools/harness/spirv_harness
    ln -s ${python}/bin/python3 $dest/tools/linux/python/bin/python3
    ln -s ${pkgs.zig}/bin/zig $dest/tools/linux/zig/zig
    makeWrapper ${launcher}/bin/pokopia-launcher $out/bin/recompia \
      --set RECOMPIA_DATA $dest \
      --set RECOMPIA_NIX_PACKAGE 1 \
      --prefix PATH : ${
        lib.makeBinPath [
          python
          pkgs.zig
          pkgs.xdg-utils
          pkgs.gnutar
          pkgs.gzip
        ]
      } \
      --run 'state="''${XDG_DATA_HOME:-$HOME/.local/share}/recompia"; mkdir -p "$state"; cp -rsf "$RECOMPIA_DATA"/. "$state"/; ln -sfn "@out@/bin/recompia" "$state/PokopiaLauncher.AppImage"; export APPIMAGE="$state/PokopiaLauncher.AppImage"'
    substituteInPlace $out/bin/recompia --replace-fail '@out@' "$out"
    install -Dm644 launcher/src-tauri/icons/128x128.png $out/share/icons/hicolor/128x128/apps/recompia.png
    runHook postInstall
  '';
  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "recompia";
      desktopName = "Recompia";
      exec = "recompia";
      icon = "recompia";
      categories = [ "Game" ];
    })
  ];
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.copyDesktopItems
    python
  ];
  passthru = { inherit runtime launcher shaders; };
  meta = {
    description = "Native Pokopia recompilation launcher and runtime";
    homepage = "https://github.com/Dittobyte/Recompia";
    license = lib.licenses.gpl3Plus;
    mainProgram = "recompia";
    platforms = [ "x86_64-linux" ];
  };
}
