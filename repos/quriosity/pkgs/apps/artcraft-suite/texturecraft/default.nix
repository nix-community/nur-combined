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
  pname = "texturecraft";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "texturecraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GQcV4ryTuyuy1diNGIbEi+tB1VRV89Op8WwkTKahhUM=";
  };

  cargoHash = "sha256-2wzPv69KwudY/5vVxiIL0YhLfp2AvDAUGxeRgYKg7G8=";
  cargoBuildFlags = [ "--package" "texturecraft" "--package" "texturecraft-cli" ];
  cargoTestFlags = [ "--package" "texturecraft" "--package" "texturecraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.texturecraft.desktop \
      $out/share/applications/ai.storyteller.texturecraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.texturecraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.texturecraft.metainfo.xml

    wrapProgram $out/bin/texturecraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "TextureCraft: An open-source, 3D texture painting workflow written from scratch in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "texturecraft";
  };
})