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
  pname = "wordcraft";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "wordcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SfrnSydUVuh+3tJ69OINsc1thkubgVh8aEVBfZyXmsM=";
  };

  cargoHash = "sha256-D/CRhDoUbKvz/ev8NKRm2aDEyOA4NL5mdnx+O+iXHRI=";
  cargoBuildFlags = [ "--package" "wordcraft" "--package" "wordcraft-cli" ];
  cargoTestFlags = [ "--package" "wordcraft" "--package" "wordcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.wordcraft.desktop \
      $out/share/applications/ai.storyteller.wordcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.wordcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.wordcraft.metainfo.xml

    wrapProgram $out/bin/wordcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Microsoft Word in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "wordcraft";
  };
})