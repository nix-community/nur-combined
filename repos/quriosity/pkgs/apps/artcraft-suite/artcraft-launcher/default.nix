{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  autoPatchelfHook,
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
  ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "artcraft-launcher";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-launcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-tu+D3BMsriY5YEIYHETHNyAaFGdeoxjxBNGA6AcqU/c=";
  };

  cargoHash = "sha256-slEa9dK1sVkP8+KoFDF2Vv+NThrid1Z8jdWAGgP5FFQ=";
  cargoBuildFlags = [ "--package" "artcraft-launcher" ];
  cargoTestFlags = [ "--package" "artcraft-launcher" ];

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.artcraft-launcher.desktop \
      $out/share/applications/ai.storyteller.artcraft-launcher.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.artcraft-launcher.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.artcraft-launcher.metainfo.xml
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "One place to install, update and open every app in the Craft App Suite, rebuilt in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "artcraft-launcher";
  };
})