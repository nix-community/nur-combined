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
  pname = "gridcraft";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "gridcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8qlbNJWvONfZ8BvY8fij1QrLwoikFKBgmTiklpu4LOM=";
  };

  cargoHash = "sha256-9PJmE7dLeDIEsnczga1WfWaad1e0YLLh04rJcSyzGwE=";
  cargoBuildFlags = [ "--package" "gridcraft" "--package" "gridcraft-cli" ];
  cargoTestFlags = [ "--package" "gridcraft" "--package" "gridcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.gridcraft.desktop \
      $out/share/applications/ai.storyteller.gridcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.gridcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.gridcraft.metainfo.xml

    wrapProgram $out/bin/gridcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "GridCraft: an open-source, clean-room spreadsheet (Microsoft Excel-style) in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "gridcraft";
  };
})