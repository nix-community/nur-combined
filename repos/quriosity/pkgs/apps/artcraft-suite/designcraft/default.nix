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
  pname = "designcraft";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "designcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QYtPzieihcoTXTLxlmJ+quXVHgbvFPteLsG06aqr1ds=";
  };

  cargoHash = "sha256-R0ATPEwcXG/ufMsamau3jQ9Kytvn5ltj6Rbx1wT00oo=";
  cargoBuildFlags = [ "--package" "designcraft" "--package" "designcraft-cli" ];
  cargoTestFlags = [ "--package" "designcraft" "--package" "designcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.designcraft.desktop \
      $out/share/applications/ai.storyteller.designcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.designcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.designcraft.metainfo.xml

    wrapProgram $out/bin/designcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "an open-source, clean-room reimplementation of Adobe InDesign, rebuilt in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "designcraft";
  };
})