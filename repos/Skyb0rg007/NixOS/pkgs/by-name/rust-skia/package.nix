{
  lib,
  rustPlatform,
  clangStdenv,
  fetchCrate,
  fetchFromGitHub,
  fetchgit,
  linkFarm,
  runCommand,
  gn,
  ninja,
  pkg-config,
  python3,
  removeReferencesTo,
  fontconfig,
  freetype,
  features ? [
    "ganesh"
    "gl"
    "vulkan"
  ],
}:
# Builds the `skia-bindings` crate from source and packages the result in the
# same layout as the prebuilt archives published at
# https://github.com/rust-skia/skia-binaries.
# Consumers point skia-bindings at it with
#   SKIA_BINARIES_URL = "file://${rust-skia}/skia-binaries.tar.gz";
# The version must match the skia-bindings version in the consumer's Cargo.lock.
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } (finalAttrs: {
  pname = "rust-skia";
  version = "0.153.3";

  src = fetchCrate {
    pname = "skia-bindings";
    inherit (finalAttrs) version;
    hash = "sha256-UjFx8hTWbiPioNvhHnGTLpfFTQI3A16DImKIuqx05fM=";
  };

  cargoHash = "sha256-b0oS7Tl8WSEf+dUc7dzkREGIdFRkZO+021vkM3GoUf4=";

  env = {
    SKIA_SOURCE_DIR =
      let
        # see skia-bindings/Cargo.toml [package.metadata] skia
        repo = fetchFromGitHub {
          owner = "rust-skia";
          repo = "skia";
          tag = "m153-0.101.2";
          hash = "sha256-xKCkvQoTAMlLvKdVzzSxTST6kER4kRUIDjvTRZ9z72o=";
        };
        # Generated from skia/DEPS by ./update.sh
        externals = linkFarm "skia-externals" (
          lib.mapAttrsToList (name: value: {
            inherit name;
            path = fetchgit value;
          }) (lib.importJSON ./externals.json)
        );
      in
      runCommand "skia-source" { } ''
        cp -R ${repo} $out
        chmod -R +w $out
        ln -s ${externals} $out/third_party/externals
      '';
    SKIA_GN_COMMAND = lib.getExe gn;
    SKIA_NINJA_COMMAND = lib.getExe ninja;
    # third_party/freetype2/BUILD.gn hard-codes /usr/include/freetype2
    NIX_CFLAGS_COMPILE = "-isystem ${lib.getDev freetype}/include/freetype2";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
    python3
    removeReferencesTo
  ];

  buildInputs = [
    fontconfig
    freetype
  ];

  buildFeatures = features;

  doCheck = false;

  installPhase = ''
    runHook preInstall

    skia=$(echo target/*/release/build/skia-bindings-*/out/skia)
    staging=$(mktemp -d)
    mkdir $staging/skia-binaries
    cp $skia/*.a $skia/bindings.rs $staging/skia-binaries/
    cp $SKIA_SOURCE_DIR/LICENSE $staging/skia-binaries/LICENSE_SKIA
    # Skia embeds __FILE__ paths; don't drag its sources into consumers' closures
    remove-references-to -t $SKIA_SOURCE_DIR $staging/skia-binaries/*.a

    mkdir -p $out
    tar -C $staging --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
      -cf - skia-binaries | gzip -9n > $out/skia-binaries.tar.gz

    runHook postInstall
  '';

  # Follows the skia-bindings version in sequin's Cargo.lock
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Skia static libraries and Rust bindings built for the skia-bindings crate";
    homepage = "https://github.com/rust-skia/rust-skia";
    license = with lib.licenses; [
      mit
      bsd3
    ];
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
