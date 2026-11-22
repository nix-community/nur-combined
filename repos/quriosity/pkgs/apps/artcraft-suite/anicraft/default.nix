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
  pname = "anicraft";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "anicraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2y6pbiUS4h4+qgGw5xA23uHGU4/hdQpjXIhv/xetbBI=";
  };

  cargoHash = "sha256-WOPOpQGGAlxPV1C9WsqVOeqxnW34/gGAX5v1OlCHGpY=";
  cargoBuildFlags = [ "--package" "anicraft" "--package" "anicraft-cli" ];
  cargoTestFlags = [ "--package" "anicraft" "--package" "anicraft-cli" ];

  prePatch = ''
    sed -i 's/a.show_update_outcome_on_start();/\/\/ a.show_update_outcome_on_start();/' src/main.rs
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;
  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.anicraft.desktop \
      $out/share/applications/ai.storyteller.anicraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.anicraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.anicraft.metainfo.xml

    wrapProgram $out/bin/anicraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source 2D animation editor written in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "anicraft";
  };
})
