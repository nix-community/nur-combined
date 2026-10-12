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
  pname = "vectorcraft";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "vectorcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Z663KKE+y80cuKrTeTVg8V4+HFd6sM4Bg3gq7fVL2/k=";
  };

  cargoHash = "sha256-jWy29+wVqTzql0vELtwuMxc8j1LYetICPVivMqIKMkU=";
  cargoBuildFlags = [ "--package" "vectorcraft" "--package" "vectorcraft-cli" ];
  cargoTestFlags = [ "--package" "vectorcraft" "--package" "vectorcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.vectorcraft.desktop \
      $out/share/applications/ai.storyteller.vectorcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.vectorcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.vectorcraft.metainfo.xml

    wrapProgram $out/bin/vectorcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Adobe Illustrator, built in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "vectorcraft";
  };
})