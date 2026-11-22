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
  pname = "solidcraft";
  version = "0.46.2";

  src = fetchFromGitHub {
    owner = "tangency-labs";
    repo = "solidcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KE+7LzAB/QUaRNJZvsQutNNDrgubfBnPoA/WkTVbQzM=";
  };

  cargoHash = "sha256-TK9N4WPJNP7OsXzuvir+E6NUNtc6WWNtS1677lEdggw=";
  cargoBuildFlags = [ "--package" "solidcraft" "--package" "solidcraft-cli" ];
  cargoTestFlags = [ "--package" "solidcraft" "--package" "solidcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;
  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 assets/platforms/linux/io.tangencylabs.solidcraft.desktop \
      $out/share/applications/io.tangencylabs.solidcraft.desktop
    cp -r assets/icons/app/linux/exports/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      assets/platforms/linux/io.tangencylabs.solidcraft.metainfo.xml.in \
      > $out/share/metainfo/io.tangencylabs.solidcraft.metainfo.xml

    wrapProgram $out/bin/solidcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source parametric 3D CAD application built in pure Rust";
    homepage = "https://solidcraft.io/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "solidcraft";
  };
})
