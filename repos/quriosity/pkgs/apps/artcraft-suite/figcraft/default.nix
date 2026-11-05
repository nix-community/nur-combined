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

  # craft-libs is a git dependency of figcraft. We fetch it locally in prePatch
  # (before vendoring) and redirect the git deps to local path deps so
  # craft-libs never needs to be fetched during the vendor step.
  craftLibs = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-libs";
    rev = "e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545";
    hash = "sha256-yTMWFdJDxJnbwHbing7TsrbmKRMhrjceMz5RwFJYt5g=";
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "figcraft";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "figcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nkDYjqEixE1zRJj/AiqVNIHQC5XnzqTf5hZREBX1UFc=";
  };

  cargoHash = "sha256-JJiPU/L2My3aGpw00NlGwmSg4CHTpr4QiA0XvbdK0Ps=";
  cargoBuildFlags = [ "--package" "figcraft" "--package" "figcraft-cli" ];
  cargoTestFlags = [ "--package" "figcraft" "--package" "figcraft-cli" ];

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
    sed -i 's/fig.set_startup_update_check(true);/\/\/ fig.set_startup_update_check(true);/' apps/figcraft/src/main.rs
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
    install -Dm644 packaging/linux/ai.storyteller.figcraft.desktop \
      $out/share/applications/ai.storyteller.figcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.figcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.figcraft.metainfo.xml

    wrapProgram $out/bin/figcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "an open-source, clean-room reimplementation of collaborative design workflows in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "figcraft";
  };
})