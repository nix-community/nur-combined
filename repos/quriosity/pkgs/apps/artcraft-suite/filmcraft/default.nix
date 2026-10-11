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
  alsa-lib,
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
    alsa-lib
  ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "filmcraft";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "filmcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aAKyxB3r3y1IEYyMjD2CJgD118kk8OdWeVCnvM5+v+0=";
  };

  cargoHash = "sha256-oJadymZHT/paCUvI9iXlUlST4SckUpdH6r5PCJkXbXI=";
  cargoBuildFlags = [ "--package" "filmcraft" "--package" "filmcraft-cli" ];
  cargoTestFlags = [ "--package" "filmcraft" "--package" "filmcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.filmcraft.desktop \
      $out/share/applications/ai.storyteller.filmcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.filmcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.filmcraft.metainfo.xml

    wrapProgram $out/bin/filmcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Adobe Premiere Pro built in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "filmcraft";
  };
})