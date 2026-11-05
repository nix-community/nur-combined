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

  # craft-libs is a git dependency of cadcraft. We fetch it locally in prePatch
  # (before vendoring) and redirect the git deps to local path deps so
  # craft-libs never needs to be fetched during the vendor step.
  craftLibs = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-libs";
    rev = "92d392cff132eaf53e13afff77f38b5c11b73aa0";
    hash = "sha256-eF/jYZxRgaAcl5zrvhQLWv5mtt81TZzH/p3kJf3u0qw=";
  };
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

  cargoHash = "sha256-kilaA8T5ZFEn5+6Eh/8VGM4Z+WTt18u6B4zXepa7L3U=";
  cargoBuildFlags = [ "--package" "cadcraft" "--package" "cadcraft-cli" ];
  cargoTestFlags = [ "--package" "cadcraft" "--package" "cadcraft-cli" ];

  prePatch = ''
    # Remove patch entries that Cargo.lock reports as unused.
    unused_names=$(awk '/^\[\[patch\.unused\]\]/{getline; match($0,/name = "([^"]+)"/,m); if (m[1] != "") print m[1]}' Cargo.lock | sort -u)
    for crate in $unused_names; do
      if [ -f Cargo.toml ]; then
        awk -v c="$crate" '$0 !~ "^" c " = " {print}' Cargo.toml > Cargo.toml.tmp
        mv Cargo.toml.tmp Cargo.toml
      fi
    done

    if [ -n "$unused_names" ]; then
      awk -v names="$unused_names" '
        BEGIN {
          n=split(names, a, "\n")
          for (i=1;i<=n;i++) if (a[i] != "") want[a[i]]=1
          skip=0
        }
        /^\[\[patch\.unused\]\]$/ {
          getline nameline
          name=""
          if (match(nameline, /name = "([^"]+)"/, m)) name=m[1]
          if (name != "" && want[name] == 1) {
            while ((getline line) > 0 && line != "") { }
            next
          } else {
            print "[[patch.unused]]"
            print nameline
            next
          }
        }
        { print }
      ' Cargo.lock > Cargo.lock.tmp
      mv Cargo.lock.tmp Cargo.lock
    fi


    # Copy craft-libs into the source tree so it's available before vendoring.
    cp -r ${craftLibs} ./craft-libs
    chmod -R u+w ./craft-libs

    # craft-libs's crates/menu/Cargo.toml overrides workspace's craft-keymap
    # with `default-features = false`, which Cargo forbids. Remove it.
    sed -i 's/default-features = false, //' ./craft-libs/crates/menu/Cargo.toml

    # Redirect craft-libs git dependencies to local path deps
    for crate in $(grep -oP '^craft-[a-z-]+ = {[^}]*git = "https://github.com/storytold/craft-libs"' Cargo.toml | sed 's/ = .*//'); do
      dir=$(echo "$crate" | sed 's/^craft-//')
      sed -i "|$crate = {[^}]*git = "https://github.com/storytold/craft-libs"[^}]*}|$crate = { path = "./craft-libs/crates/$dir" }|" Cargo.toml
    done

    cp Cargo.lock "$cargoDepsCopy/Cargo.lock"

    # Remove git source lines from Cargo.lock for crates now using local paths
    awk '
      /^[[package]]/ { in_pkg = 1; name = "" }
      in_pkg && /^name = / { name = $0; sub(/^name = ""/, "", name); sub(/".*$/, "", name) }
      in_pkg && name ~ /^craft-/ && /^source = "git+https://github.com/storytold/craft-libs/ { next }
      { print }
    ' Cargo.lock > Cargo.lock.tmp && mv Cargo.lock.tmp Cargo.lock


    # Отключаем автоматическую проверку обновлений при старте приложения.
    sed -i 's/app.enable_update_check();/\/\/ app.enable_update_check();/' apps/cadcraft/src/main.rs
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