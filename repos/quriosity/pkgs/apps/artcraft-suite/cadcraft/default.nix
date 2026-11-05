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

    cp Cargo.lock "$cargoDepsCopy/Cargo.lock"

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