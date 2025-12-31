{
  copyDesktopItems,
  dart,
  imagemagick,
  lib,
  libsecret,
  flutter338,
  fetchFromGitHub,
  makeDesktopItem,
  nix-update-script,
  runCommand,
  yq-go,
  _experimental-update-script-combinators,
}:
let
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Celechron";
    repo = "Celechron";
    tag = version;
    hash = "sha256-+mjq/5da7BMqCoGyXXnFOvFOgDE/p60ik8jEKVrEokw=";
  };
in
flutter338.buildFlutterApplication {
  inherit src version;
  pname = "celechron";

  patches = [
    ./0001-fix-title-bar.patch
  ];

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = lib.importJSON ./git-hashes.json;

  buildInputs = [
    libsecret
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

  # Wait for upstream to upgrade flutter_secure_storage to 10.0.0
  CXXFLAGS = [ "-Wno-deprecated-literal-operator" ];

  postInstall = ''
    # Generate and install icon files
    for size in 16 32 48 64 72 96 128 192 512 1024; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      magick assets/logo.png \
        -sample "$size"x"$size" \
        -extent "$size"x"$size" \
        $out/share/icons/hicolor/"$size"x"$size"/apps/celechron.png
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "xyz.nosig.celechron";
      exec = "celechron";
      icon = "celechron";
      desktopName = "Celechron";
      genericName = "Celechron";
      startupWMClass = "xyz.nosig.celechron";
      comment = "服务于浙大学生的时间管理器";
      categories = [
        "Education"
        "Utility"
      ];
    })
  ];
  passthru = {
    pubspecSource =
      runCommand "pubspec.lock.json"
        {
          inherit src;
          nativeBuildInputs = [ yq-go ];
        }
        ''
          yq eval --output-format=json --prettyPrint $src/pubspec.lock > "$out"
        '';
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { })
      (
        (_experimental-update-script-combinators.copyAttrOutputToFile "celechron.pubspecSource" ./pubspec.lock.json)
        // {
          supportedFeatures = [ ];
        }
      )
      {
        command = [
          dart.fetchGitHashesScript
          "--input"
          ./pubspec.lock.json
          "--output"
          ./git-hashes.json
        ];
        supportedFeatures = [ ];
      }
    ];
  };

  meta = {
    description = "服务于浙大学生的时间管理器";
    homepage = "https://github.com/Celechron/Celechron";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "celechron";
    platforms = lib.platforms.all;
  };
}
