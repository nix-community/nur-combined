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
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "cadcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qRzZk4M5hk+zTDq9IK9zy4aoK+hkeomVkS1BNfFqtW8=";
  };

  # Patch craft-libs before cargo vendor scans its workspace manifests.
  cargoHash = "sha256-ZxT3g5vQA7noA5qKhTnlP8AiPZlIUyzUne4y/VfgiJc=";
  depsExtraArgs.postBuild = ''
    menuManifest="$out/git/92d392cff132eaf53e13afff77f38b5c11b73aa0/crates/menu/Cargo.toml"
    if [ ! -f "$menuManifest" ]; then
      echo "craft-libs menu manifest not found in cargo vendor staging" >&2
      exit 1
    fi
    sed -i 's/default-features = false, //' "$menuManifest"
  '';
  cargoBuildFlags = [ "--package" "cadcraft" "--package" "cadcraft-cli" ];
  cargoTestFlags = [ "--package" "cadcraft" "--package" "cadcraft-cli" ];

  prePatch = ''
    # Cargo.lock lists some egui crates under [[patch.unused]] because the app
    # pins them in [patch.crates-io], but the reviewed egui fork does not ship
    # them. Cargo refuses to build when a patch points at a missing package, so
    # drop both the unused patch entries and their lockfile blocks.
    unused_names=$(awk '/^\[\[patch\.unused\]\]/{getline; if (match($0,/name = "([^"]+)"/,m)) print m[1]}' Cargo.lock | sort -u)
    if [ -n "$unused_names" ]; then
      for crate in $unused_names; do
        sed -i "/^$crate = /d" Cargo.toml
      done
      awk '
        /^\[\[patch\.unused\]\]$/ { skip = 1; next }
        skip && /^$/ { skip = 0; next }
        !skip { print }
      ' Cargo.lock > Cargo.lock.tmp
      mv Cargo.lock.tmp Cargo.lock
    fi

    # Disable the automatic update check in cadcraft (it tries to fetch from the internet, which is not allowed in Nix builds).
    sed -i 's/app.enable_update_check();/\/\/ app.enable_update_check();/' apps/cadcraft/src/main.rs
  '';
  postPatch = ''
    # Keep the vendored lockfile in sync with the patched one above.
    cp Cargo.lock "$cargoDepsCopy/Cargo.lock"
  '';
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