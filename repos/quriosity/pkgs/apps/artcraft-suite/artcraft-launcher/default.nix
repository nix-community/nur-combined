{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  autoPatchelfHook,
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

  # craft-libs is a git dependency of craft-launcher (craft-ui, craft-quit,
  # craft-fonts-build, craft-i18n all come from it). Its crates/menu/Cargo.toml
  # overrides the workspace's craft-keymap with `default-features = false`,
  # which Cargo rejects when cargo metadata runs during vendoring. We fetch
  # craft-libs locally in prePatch (before vendoring) and redirect the git
  # deps to local path deps so craft-libs never needs to be fetched during the
  # vendor step.
  craftLibs = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-libs";
    rev = "92d392cff132eaf53e13afff77f38b5c11b73aa0";
    hash = "sha256-/8I9DcqtsznoYPo4ECc/rPQIal6P9gyPksrvVHDW6Mg=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "artcraft-launcher";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-launcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-B9fL7JhAetm9qysaXpsnRyBBSQiNhUD1NeElYefr2+c=";
  };

  cargoHash = "sha256-EjNtS12zO0j9o3Hr88I+uCqK7mtKiRGvHkIXFY2oRu4=";
  cargoPatches = [ ./remove-unused-egui-patches.patch ];
  prePatch = ''
    # Copy craft-libs into the source tree so it's available before vendoring.
    cp -r ${craftLibs} ./craft-libs
    chmod -R u+w ./craft-libs

    # craft-libs's crates/menu/Cargo.toml overrides workspace's craft-keymap
    # with `default-features = false`, which Cargo forbids. Remove it.
    sed -i 's/default-features = false, //' ./craft-libs/crates/menu/Cargo.toml

    # Optional/unvendored deps of craft-libs crates (not in Cargo.lock).
    # Remove them so the offline build doesn't look for them.
    sed -i '/^fontique = /d' ./craft-libs/crates/ui/Cargo.toml
    sed -i '/^unicode-script = /d' ./craft-libs/crates/ui/Cargo.toml
    sed -i 's/system_fonts = \["dep:fontique", "dep:unicode-script"\]/system_fonts = []/' ./craft-libs/crates/ui/Cargo.toml
    sed -i '/^wasm-bindgen-test = /d' ./craft-libs/crates/ui/Cargo.toml
    sed -i '/^skera = /d' ./craft-libs/crates/fonts-build/Cargo.toml
    sed -i '/^skrifa = /d' ./craft-libs/crates/fonts-build/Cargo.toml
    sed -i 's/subset = \["dep:skera", "dep:skrifa"\]/subset = []/' ./craft-libs/crates/fonts-build/Cargo.toml
    sed -i '/^icu_collator = /d' ./craft-libs/crates/i18n/Cargo.toml
    sed -i '/dep:icu_collator/d' ./craft-libs/crates/i18n/Cargo.toml

    # Redirect craft-ui from git to local path dep
    sed -i 's|craft-ui = { version = "=0.1.0", git = "https://github.com/storytold/craft-libs", rev = "92d392cff132eaf53e13afff77f38b5c11b73aa0" }|craft-ui = { path = "./craft-libs/crates/ui" }|' Cargo.toml

    # Disable the automatic update check in craft-ui (it tries to fetch from the internet, which is not allowed in Nix builds).
    sed -i 's/check_every: CheckEvery::Hour,/check_every: CheckEvery::Never,/' crates/ui-egui/src/settings.rs

    # Disable the self-update feature in craft-ui (it tries to fetch from the internet, which is not allowed in Nix builds).
    sed -i 's/self_update: self.shared.self_install.get().is_some_and(Option::is_some)/self_update: false/' crates/native/src/backend.rs

    # Redirect craft-quit from git to local path dep
    sed -i 's|craft-quit = { version = "0.1.0", git = "https://github.com/storytold/craft-libs", rev = "92d392cff132eaf53e13afff77f38b5c11b73aa0", features = \["egui"\] }|craft-quit = { path = "../../craft-libs/crates/quit", features = ["egui"] }|' apps/artcraft-launcher/Cargo.toml

    # craft-ui and craft-quit reference craft-fonts-build and craft-i18n as
    # workspace deps; since they are now path deps inside this source tree,
    # add them to this workspace's dependencies.
    sed -i '/^craft-update = { version = "=0.1.0", git/a\craft-fonts-build = { path = "./craft-libs/crates/fonts-build" }\ncraft-i18n = { path = "./craft-libs/crates/i18n" }' Cargo.toml

    # Update Cargo.lock: remove git source lines for crates that are now path deps
    awk '
      /^\[\[package\]\]/ { in_pkg = 1; name = "" }
      in_pkg && /^name = / { name = $0; sub(/^name = "/, "", name); sub(/".*$/, "", name) }
      in_pkg && name ~ /^(craft-ui|craft-quit|craft-fonts-build|craft-i18n)$/ && /^source = "git\+https:\/\/github\.com\/storytold\/craft-libs\?rev=92d392c/ { next }
      { print }
    ' Cargo.lock > Cargo.lock.tmp && mv Cargo.lock.tmp Cargo.lock
  '';
  postPatch = ''
    # Keep the vendored lockfile in sync with the patched one above.
    cp Cargo.lock "$cargoDepsCopy/Cargo.lock"
  '';
  cargoBuildFlags = [ "--package" "artcraft-launcher" ];
  cargoTestFlags = [ "--package" "artcraft-launcher" ];

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.artcraft-launcher.desktop \
      $out/share/applications/ai.storyteller.artcraft-launcher.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.artcraft-launcher.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.artcraft-launcher.metainfo.xml
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "One place to install, update and open every app in the Craft App Suite, rebuilt in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "artcraft-launcher";
  };
})
