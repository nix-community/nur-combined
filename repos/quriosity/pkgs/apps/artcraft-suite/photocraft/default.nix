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
  pname = "photocraft";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "photocraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-muKVyGM/lG0Ffav5wk4SbinrPkoCzvBYmcpM/Vwp6bk=";
  };

  cargoHash = "sha256-PQZGEtDvB6qb2arHuxGfz7Z+Pr1mCF/MrMI2yUGoV74=";
  cargoBuildFlags = [ "--package" "photocraft" "--package" "photocraft-cli" ];
  cargoTestFlags = [ "--package" "photocraft" "--package" "photocraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.photocraft.desktop \
      $out/share/applications/ai.storyteller.photocraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.photocraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.photocraft.metainfo.xml

    wrapProgram $out/bin/photocraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Adobe Photoshop in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "photocraft";
  };
})