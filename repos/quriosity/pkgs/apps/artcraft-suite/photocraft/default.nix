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
  dbus,
  writeShellScriptBin,
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
  pname = "photocraft";
  version = "0.20.2";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "photocraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GIaCBK5zDpnOwNbefv+igBbQSVhC1KfRTP9OJj2zPYI=";
  };

  cargoHash = "sha256-FYHbqEMhmLkQ/h1CAK9pZe/Rkn+jTNB0waiD+bu8uX0=";
  cargoBuildFlags = [ "--package" "photocraft" "--package" "photocraft-cli" ];
  cargoTestFlags = [ "--package" "photocraft" "--package" "photocraft-cli" ];

  prePatch = ''
    # Cargo.lock lists some egui crates under [[patch.unused]] because the app
    # pins them in [patch.crates-io], but the reviewed egui fork does not ship
    # them. Cargo refuses to build when a patch points at a missing package, so
    # drop both the unused patch entries and their lockfile blocks.
    # All awk scripts written to files to avoid Nix string quoting issues
    cat > /tmp/extract-unused.awk << 'EOF'
/^\[\[patch\.unused\]\]/ {
  getline
  gsub(/.*name = "/, "")
  gsub(/".*/, "")
  print
}
EOF
    unused_names=$(awk -f /tmp/extract-unused.awk Cargo.lock | sort -u)
    if [ -n "$unused_names" ]; then
      # Export for awk scripts
      export unused_names
      cat > /tmp/filter-toml.awk << 'EOF'
BEGIN { n=split(ENVIRON["unused_names"],a,"\n"); for (i=1;i<=n;i++) if (a[i] != "") want[a[i]]=1 }
/^\[/ { section=$0 }
section == "[patch.crates-io]" && /^[A-Za-z0-9_-]+ = / { if ($1 in want) next }
{ print }
EOF
      awk -f /tmp/filter-toml.awk Cargo.toml > Cargo.toml.tmp
      mv Cargo.toml.tmp Cargo.toml

      cat > /tmp/remove-unused-lock.awk << 'EOF'
BEGIN { n=split(ENVIRON["unused_names"],a,"\n"); for (i=1;i<=n;i++) if (a[i] != "") want[a[i]]=1 }
/^\[\[patch\.unused\]\]$/ {
  getline nameline
  name=""
  if (match(nameline, /name = "([^"]+)"/)) name=substr(nameline, RSTART+6, RLENGTH-7)
  if (name != "" && want[name] == 1) {
    while ((getline line) > 0 && line != "") { }
    next
  }
  print "[[patch.unused]]"
  print nameline
  next
}
{ print }
EOF
      awk -f /tmp/remove-unused-lock.awk Cargo.lock > Cargo.lock.tmp
      mv Cargo.lock.tmp Cargo.lock
    fi
    sed -i 's/automatically_check_updates: true,/automatically_check_updates: false,/' crates/engine/src/prefs.rs
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

  # The portal tests spawn a private `dbus-daemon` session bus. In the build sandbox there
  # is no `/etc/dbus-1/session.conf`, so `--session` aborts without printing an address and
  # the tests fail on `Address("Invalid address")`. Point dbus at its own packaged config.
  nativeCheckInputs = [
    (writeShellScriptBin "dbus-daemon" ''
      args=()
      has_config=0
      for arg in "$@"; do
        case "$arg" in
          --session) ;;
          --config-file*) has_config=1; args+=("$arg") ;;
          *) args+=("$arg") ;;
        esac
      done
      if [ "$has_config" = 0 ]; then
        args+=(--config-file="${dbus}/share/dbus-1/session.conf")
      fi
      exec "${dbus}/bin/dbus-daemon" "''${args[@]}"
    '')
  ];

  buildInputs = runtimeLibs;

  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/ai.storyteller.photocraft.desktop \
      $out/share/applications/ai.storyteller.photocraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.photocraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.photocraft.metainfo.xml

    wrapProgram $out/bin/photocraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Adobe Photoshop in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "photocraft";
  };
})