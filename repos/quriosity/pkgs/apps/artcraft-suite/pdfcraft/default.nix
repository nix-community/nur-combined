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
  pname = "pdfcraft";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "pdfcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FddJfmHevL1vwDufjFReWBlocDYZihYhiFLgMZBhiPE=";
  };

  cargoHash = "sha256-Sq2DWsBHzR/kTbiDjCcLVqLd66MF6dzUl/MtaU1EK/g=";
  cargoBuildFlags = [ "--package" "pdfcraft" "--package" "pdfcraft-cli" ];
  cargoTestFlags = [ "--package" "pdfcraft" "--package" "pdfcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postPatch = ''
    patch -p1 -d "$cargoDepsCopy"/*/rten-gemm-* \
      < ${./rten-gemm-no-vnni-intrinsic.patch}
  '';

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.pdfcraft.desktop \
      $out/share/applications/ai.storyteller.pdfcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.pdfcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.pdfcraft.metainfo.xml

    wrapProgram $out/bin/pdfcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Adobe Acrobat built in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "pdfcraft";
  };
})