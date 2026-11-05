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

  # craft-libs is a git dependency of wordcraft (craft-pdf, craft-ui,
  # craft-i18n, craft-fonts-build, craft-keymap all come from it). Its
  # crates/menu/Cargo.toml overrides the workspace's craft-keymap with
  # `default-features = false`, which Cargo rejects. We fetch craft-libs
  # locally in prePatch (before vendoring) and redirect the git deps to
  # local path deps so craft-libs never needs to be fetched during the
  # vendor step.
  craftLibs = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-libs";
    rev = "92d392cff132eaf53e13afff77f38b5c11b73aa0";
    hash = "sha256-/8I9DcqtsznoYPo4ECc/rPQIal6P9gyPksrvVHDW6Mg=";
  };
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
    done

    # Copy craft-libs into the source tree so it's available before vendoring.
    cp -r ${craftLibs} ./craft-libs
    chmod -R u+w ./craft-libs

    # craft-libs's crates/menu/Cargo.toml overrides workspace's craft-keymap
    # with `default-features = false`, which Cargo forbids. Remove it.
    sed -i 's/default-features = false, //' ./craft-libs/crates/menu/Cargo.toml

    # Redirect craft-pdf from git to local path dep
    sed -i 's|craft-pdf = { git = "https://github.com/storytold/craft-libs", rev = "92d392cff132eaf53e13afff77f38b5c11b73aa0", version = "=0.1.0", default-features = false, features = \\["write"\\] }|craft-pdf = { path = "./craft-libs/crates/pdf", default-features = false, features = ["write"] }|' Cargo.toml

    cp Cargo.lock "$cargoDepsCopy/Cargo.lock"

    # Disable the automatic update check in wordcraft (it tries to fetch from the internet, which is not allowed in Nix builds).
    sed -i 's/app.set_startup_update_check(true);/\/\/ app.set_startup_update_check(true);/' apps/wordcraft/src/main.rs
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