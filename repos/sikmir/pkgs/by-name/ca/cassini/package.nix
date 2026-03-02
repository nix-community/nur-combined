{
  lib,
  stdenv,
  cctools,
  fetchFromGitHub,
  fetchgit,
  gn,
  linkFarm,
  ninja,
  python3,
  removeReferencesTo,
  runCommand,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cassini";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "NicoRio42";
    repo = "cassini";
    tag = finalAttrs.version;
    hash = "sha256-6KfsB8yz0iXifknSFUi3AayBiNjuVtLFDSBXUkQ6zek=";
  };

  cargoHash = "sha256-itHY9LAIQf94rdEdHCWIGBLaD8D4c0id4DDSyU3TIt0=";

  nativeBuildInputs = [
    python3 # skia
    removeReferencesTo
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools.libtool
  ];

  buildInputs = [
    rustPlatform.bindgenHook
  ];

  postFixup = ''
    # library skia embeds the path to its sources
    remove-references-to -t "$SKIA_SOURCE_DIR" \
      $out/bin/cassini
  '';

  env = {
    SKIA_SOURCE_DIR =
      let
        repo = fetchFromGitHub {
          owner = "rust-skia";
          repo = "skia";
          # see rust-skia:skia-bindings/Cargo.toml#package.metadata skia
          rev = "refs/tags/m126-0.74.2";
          hash = "sha256-4l6ekAJy+pG27hBGT6A6LLRwbsyKinJf6PP6mMHwaAs=";
        };
        # The externals for skia are taken from skia/DEPS
        # Reduced to only what's necessary
        externals = linkFarm "skia-externals" (
          lib.mapAttrsToList (name: value: {
            inherit name;
            path = fetchgit value;
          }) (lib.importJSON ./skia-externals.json)
        );
      in
      runCommand "source" { } ''
        cp -R ${repo} $out
        chmod -R +w $out
        ln -s ${externals} $out/third_party/externals
      '';
    SKIA_GN_COMMAND = lib.getExe gn;
    SKIA_NINJA_COMMAND = lib.getExe ninja;
  };

  disallowedReferences = [ finalAttrs.env.SKIA_SOURCE_DIR ];

  meta = {
    description = "A software that generates highly accurate topographic maps from LiDAR and Shapefile data";
    homepage = "https://cassini-map.com";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.hostPlatform.isLinux;
  };
})
