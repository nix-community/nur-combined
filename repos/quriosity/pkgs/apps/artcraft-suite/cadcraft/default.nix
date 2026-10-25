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
  pname = "cadcraft";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "cadcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lS9E30whUfGNq82jpgmJB5q3W81zZQNmqg0TcM1ul1M=";
  };

  cargoHash = "sha256-BE34VV7+IwbpLvEMO61ombOGdcytlq2B7BJPWGjpdvA=";
  cargoBuildFlags = [ "--package" "cadcraft" "--package" "cadcraft-cli" ];
  cargoTestFlags = [ "--package" "cadcraft" "--package" "cadcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.cadcraft.desktop \
      $out/share/applications/ai.storyteller.cadcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.cadcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.cadcraft.metainfo.xml

    wrapProgram $out/bin/cadcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "an open-source, clean-room AutoCAD-style app in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "cadcraft";
  };
})