{
  lib,
  coreutils,
  rustPlatform,
  fetchFromGitHub,
  gitMinimal,
  qt6,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rimstack";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "TheForgotten69";
    repo = "RimStack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZJc/67nHd05jFBRB0nXjs1+Blbu5mvWPhbemjLZyPUo=";
  };

  cargoHash = "sha256-FUvwUv/lCgaBhkj2iEvnX3VlQBVfOGrEXqNpnmD1h40=";

  # qt-build-utils discovers Qt only through a single qmake, whose queries
  # point into the qtbase store path, so:
  # - every other Qt module that cxx-qt links (the Qml module lives in the
  #   qtdeclarative output) keeps its .prl link files in its own store path;
  #   merge lib, include and the libexec tools into one symlink tree and
  # - wrap qmake to answer those queries with the tree instead.
  # The wrapper is created during the build itself, so QMAKE is exported here.
  postPatch =
    let
      qtRuntime = [
        qt6.qtbase
        qt6.qtdeclarative
        qt6.qtsvg
      ];
      qmake = lib.getExe' qt6.qtbase "qmake";
    in
    ''
      substituteInPlace crates/core/src/sources/maintenance.rs \
        crates/app/src/workspace/load_order/tests.rs \
        --replace-fail '"/bin/sleep"' '"${lib.getExe' coreutils "sleep"}"'
      qtRoot="$NIX_BUILD_TOP/qt-merged"
      mkdir -p "$qtRoot/lib" "$qtRoot/include" "$qtRoot/bin" "$qtRoot/libexec"
    ''
    + lib.concatMapStrings (pkg: ''
      for f in ${lib.getLib pkg}/lib/libQt6*; do
        ln -s "$f" "$qtRoot/lib/"
      done
      for d in ${pkg.out}/include/*; do
        [ -d "$d" ] || continue
        ln -s "$d" "$qtRoot/include/"
      done
      for f in ${pkg.out}/libexec/*; do
        [ -f "$f" ] || continue
        ln -s "$f" "$qtRoot/libexec/"
      done
    '') qtRuntime
    + ''
      cat > "$qtRoot/bin/qmake" <<EOF
      #!/bin/sh
      case "\$1 \$2" in
        "-query QT_INSTALL_LIBS") echo "$qtRoot/lib"; exit 0 ;;
        "-query QT_INSTALL_HEADERS") echo "$qtRoot/include"; exit 0 ;;
        "-query QT_HOST_LIBEXECS") echo "$qtRoot/libexec"; exit 0 ;;
      esac
      exec ${qmake} "\$@"
      EOF
      chmod +x "$qtRoot/bin/qmake"
      export QMAKE="$qtRoot/bin/qmake"
    '';

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    gitMinimal # tests build throw-away mod repositories with git
  ];

  buildInputs = with qt6; [
    qtbase
    qtdeclarative # QtQuick + QuickControls2, used through cxx-qt
    qtsvg
  ];

  postInstall = ''
    install -Dm644 crates/app/assets/rimstack.desktop -t $out/share/applications
    install -Dm644 crates/app/assets/rimstack.svg $out/share/icons/hicolor/scalable/apps/rimstack.svg
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A fast RimWorld mod manager written in Rust";
    homepage = "https://github.com/TheForgotten69/RimStack";
    license = lib.licenses.gpl3Plus;
    mainProgram = "rimstack";
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    platforms = lib.platforms.linux;
  };
})
