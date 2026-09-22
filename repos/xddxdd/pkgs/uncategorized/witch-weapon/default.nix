{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  godot_4_7,
  makeDesktopItem,
  alsa-lib,
  fontconfig,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  udev,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "witch-weapon";
  version = "1.4.2-unstable-2026-08-13";

  src = fetchFromGitHub {
    owner = "YANG301";
    repo = "Witch-Weapon-Godot-";
    rev = "0b28a8dd1fccbb9a9e2620a86b58fd3c75aef8ee";
    hash = "sha256-Pn8gs5D0spIzX9gmV0ORzvt65hztDYkxX3ok6f5IYw0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    godot_4_7
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    libpulseaudio
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    udev
    vulkan-loader
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "witch-weapon";
      desktopName = "Witch Weapon";
      comment = "Fan remake of the Witch Weapon story built with Godot";
      exec = "witch-weapon";
      icon = "witch-weapon";
      categories = [ "Game" ];
    })
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    export XDG_DATA_HOME="$HOME/.local/share"
    mkdir -p "$XDG_DATA_HOME/godot"
    ln -s "${godot_4_7.export-templates-bin}/share/godot/export_templates" \
      "$XDG_DATA_HOME/godot/export_templates"

    mkdir -p build
    ${lib.getExe godot_4_7} --headless --export-release "Linux" build/witch-weapon

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 build/witch-weapon $out/libexec/witch-weapon
    patchelf \
      --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      --set-rpath ${lib.makeLibraryPath finalAttrs.buildInputs} \
      $out/libexec/witch-weapon

    install -Dm644 assets/gui/window_icon.png \
      $out/share/icons/hicolor/96x96/apps/witch-weapon.png
    mkdir -p $out/bin
    ln -s $out/libexec/witch-weapon $out/bin/witch-weapon

    runHook postInstall
  '';

  dontStrip = true;
  dontPatchELF = true;

  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    description = "Fan-made Godot remake of the Witch Weapon story";
    homepage = "https://github.com/YANG301/Witch-Weapon-Godot-";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "witch-weapon";
    platforms = [ "x86_64-linux" ];
  };
})
