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
  pname = "wordcraft";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "wordcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-e6L//Dhvziy4d6thhJ9tnjKwiiO+hB9lDq3DOX43Meo=";
  };

  cargoHash = "sha256-HfzRe099PpXccZ9lGdNjAgr7WH/38t3H1d6Eq+4WXIU=";
  cargoBuildFlags = [ "--package" "wordcraft" "--package" "wordcraft-cli" ];
  cargoTestFlags = [ "--package" "wordcraft" "--package" "wordcraft-cli" ];

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
    sed -i 's/app.set_startup_update_check(true);/\/\/ app.set_startup_update_check(true);/' apps/wordcraft/src/main.rs
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
    install -Dm644 packaging/linux/ai.storyteller.wordcraft.desktop \
      $out/share/applications/ai.storyteller.wordcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/ai.storyteller.wordcraft.metainfo.xml.in \
      > $out/share/metainfo/ai.storyteller.wordcraft.metainfo.xml

    wrapProgram $out/bin/wordcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source, clean-room reimplementation of Microsoft Word in pure Rust";
    homepage = "https://getartcraft.com/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "wordcraft";
  };
})