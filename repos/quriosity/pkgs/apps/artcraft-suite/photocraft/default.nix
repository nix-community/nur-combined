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

    # Отключаем автоматическую проверку обновлений внутри приложения.
    sed -i 's/automatically_check_updates: true,/automatically_check_updates: false,/' crates/engine/src/prefs.rs
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