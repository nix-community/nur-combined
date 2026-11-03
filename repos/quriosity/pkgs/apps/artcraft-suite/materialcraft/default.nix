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
  pname = "materialcraft";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "materialcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-v95y8NIEr1G8fMJEHaQmw1eUoCcsDHousVwUJnRjnY8=";
  };

  cargoHash = "sha256-ig8mjqF1wDg3ccAE05vqsWX6pH9f8yxeoTDTTerw5To=";
  cargoBuildFlags = [ "--package" "materialcraft" "--package" "materialcraft-cli" ];
  cargoTestFlags = [ "--package" "materialcraft" "--package" "materialcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.materialcraft.desktop \
      $out/share/applications/ai.storyteller.materialcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.materialcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.materialcraft.metainfo.xml

    wrapProgram $out/bin/materialcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "MaterialCraft: An open-source, node-based material designer written from scratch in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "materialcraft";
  };
})