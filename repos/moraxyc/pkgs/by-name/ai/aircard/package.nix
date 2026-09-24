{
  lib,
  stdenv,
  apple-sdk,
  swift,
  xcbuild,
  python3,
  yq-go,
  zip,
  darwin,
  darwinMinVersionHook,

  sources,
  source ? sources.aircard,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  strictDeps = true;
  __structuredAttrs = true;
  enableParallelBuilding = true;

  nativeBuildInputs = [
    darwin.autoSignDarwinBinariesHook
    swift
    xcbuild # for plutil
    yq-go
  ];

  buildInputs = [
    apple-sdk
    (darwinMinVersionHook "14.0")
  ];

  postPatch = ''
    # Let nixpkgs handle signing after fixup.
    substituteInPlace Makefile \
      --replace-fail $'\tcodesign --force --sign - $@' $'\t:'

    substituteInPlace AirCardApp.swift \
      --replace-fail '"/usr/bin/python3"' '"${python3}/bin/python3"' \
      --replace-fail '"/usr/bin/zip"' '"${zip}/bin/zip"'
  '';

  makeFlags = [
    "CLANG:=$(CC)"
    "CFLAGS=-fobjc-arc -O2 -Wall -Wextra"
    "MOBILEDEVICE=build/MOBILEDEVICE.tbd"
    "AIRTRAFFIC=build/AIRTRAFFIC.tbd"
  ];

  # Upstream declares the private APIs in each helper and their library paths in Makefile.
  preBuild = ''
    mkdir -p build
    for entry in MOBILEDEVICE:device_helper AIRTRAFFIC:airtraffic_host; do
      variable=''${entry%%:*}
      source=Sources/''${entry#*:}.m
      install_name=$(sed -nE "s|^$variable[[:space:]]*:=[[:space:]]*([^[:space:]]+)$|\1|p" Makefile)
      symbols=$(sed -nE 's/^extern[^(]*[ *]([[:alnum:]_]+)[[:space:]]*\(.*/_\1/p' "$source")
      {
        printf '%s ' '---'
        install_name="$install_name" symbols="$symbols" yq -n '
          .archs = ["arm64", "x86_64"] |
          .platform = "macosx" |
          .install-name = strenv(install_name) |
          .exports = [{"archs": .archs, "symbols": (strenv(symbols) | split("\n"))}] |
          . tag = "!tapi-tbd-v3"
        '
        printf '%s\n' '...'
      } > "build/$variable.tbd"
    done
  '';

  postBuild = ''
    swiftc \
      -O \
      -parse-as-library \
      AirCardApp.swift \
      -o build/AirCard
  '';

  installPhase = ''
    runHook preInstall

    app=$out/Applications/AirCard.app

    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources/bin"

    sed -n '/^<?xml /,/^<\/plist>/p' build.sh > "$app/Contents/Info.plist"
    plutil -replace LSMinimumSystemVersion -string 14.0 "$app/Contents/Info.plist"

    install -Dm755 build/AirCard "$app/Contents/MacOS/AirCard"
    install -Dm755 build/device_helper build/airtraffic_host -t "$app/Contents/Resources/bin"
    install -Dm644 aircard.py aircard_backend.py apply_card_skin.py card_assets.py dmg_assets/AppIcon.icns -t "$app/Contents/Resources"

    runHook postInstall
  '';

  meta = {
    description = "Apple Wallet card skinner and lock screen passcode themer for iOS";
    homepage = "https://github.com/Mak5er/AirCard";
    changelog = "https://github.com/Mak5er/AirCard/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
})
