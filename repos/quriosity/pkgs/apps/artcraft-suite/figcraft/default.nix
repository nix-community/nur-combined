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
  pname = "figcraft";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "figcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-m/esZA+zHBEEsJxtorMF00NhlCkrFj7p6sFWOJt4JAY=";
  };

  cargoHash = "sha256-EB/qkhEhZil1YxItkg+OAWl9KxXAD7W5y1+dxRKuUG4=";
  cargoBuildFlags = [ "--package" "figcraft" "--package" "figcraft-cli" ];
  cargoTestFlags = [ "--package" "figcraft" "--package" "figcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.figcraft.desktop \
      $out/share/applications/ai.storyteller.figcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.figcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.figcraft.metainfo.xml

    wrapProgram $out/bin/figcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "an open-source, clean-room reimplementation of collaborative design workflows in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "figcraft";
  };
})