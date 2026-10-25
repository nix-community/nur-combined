{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  autoPatchelfHook,
  makeWrapper,
  pkg-config,
  libxcb,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  wayland,
  libxkbcommon,
  libGL,
  vulkan-loader,
  alsa-lib,
  nix-update-script,
}:

let
  runtimeLibs = [
    stdenv.cc.cc.lib
    wayland
    libxkbcommon
    libxcb
    libx11
    libxcursor
    libxi
    libxrandr
    libGL
    vulkan-loader
    alsa-lib
  ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "soundcraft";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "soundcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fwTq8t8BAmdTh9w3eEKPXv6UaHbr5mss+MouIWnDrhk=";
  };

  cargoHash = "sha256-qxoDPVOcZvzMHLnDOIrmYWcmHTjwpvbFGuVADvcHYlk=";
  cargoBuildFlags = [ "--package" "soundcraft" "--package" "soundcraft-cli" ];
  cargoTestFlags = [ "--package" "soundcraft" "--package" "soundcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.soundcraft.desktop \
      $out/share/applications/ai.storyteller.soundcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.soundcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.soundcraft.metainfo.xml

    wrapProgram $out/bin/soundcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Avid Pro Tools in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "soundcraft";
  };
})