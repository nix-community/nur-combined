{
  sources,
  version,
  srcInfo,
  lib,
  stdenv,
  flutter329,
  rustPlatform,
  writeText,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  flutter = flutter329;
  description = "Third-party Wenku8 client developed in Flutter";

  commonMeta = {
    inherit description;
    homepage = "https://github.com/niuhuan/wild";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };

  rustDep = rustPlatform.buildRustPackage rec {
    inherit (sources) pname src;
    inherit version;
    sourceRoot = "${src.name}/rust";
    cargoLock = sources.cargoLock."rust/Cargo.lock";
    doCheck = false;
    passthru.libraryPath = "lib/librust_lib_wild.so";
    meta = commonMeta;
  };
in
flutter.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version;
  inherit (srcInfo) pubspecLock;
  inherit (srcInfo) gitHashes;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  customSourceBuilders = {
    rust_lib_wild =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "rust_lib_wild";
        inherit version src;
        inherit (src) passthru;

        postPatch =
          let
            fakeCargokitCmake = writeText "FakeCargokit.cmake" ''
              function(apply_cargokit target manifest_dir lib_name any_symbol_name)
                set("''${target}_cargokit_lib" ${rustDep}/${rustDep.passthru.libraryPath} PARENT_SCOPE)
              endfunction()
            '';
          in
          ''
            cp ${fakeCargokitCmake} rust_builder/cargokit/cmake/cargokit.cmake
          '';

        installPhase = ''
          runHook preInstall

          cp -r . "$out"

          runHook postInstall
        '';
      };
  };
  desktopItems = [
    (makeDesktopItem {
      name = "wild";
      desktopName = "Wild";
      genericName = "Wild";
      exec = "wild %u";
      comment = description;
      terminal = false;
      categories = [ "Utility" ];
      icon = "wild";
    })
  ];

  postInstall = ''
    for icon in web/icons/Icon-*.png; do
      size="''${icon##*/Icon-}"
      size="''${size%.png}"
      install -Dm644 "$icon" "$out/share/icons/hicolor/''${size}x''${size}/apps/wild.png"
    done
  '';

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/wild/lib
  '';

  passthru.rustDep = rustDep;

  meta = commonMeta // {
    mainProgram = "wild";
  };
}
