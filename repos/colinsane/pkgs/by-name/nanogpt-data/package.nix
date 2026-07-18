{
  gnused,
  lib,
  nanogpt-api,
  stdenvNoCC,
  update-guard,
  updater-tools,
  writeShellApplication,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nanogpt-data";
  version = "0-unstable-2026-07-18";

  src = lib.fileset.toSource {
    root = ./.; fileset = ./models.json;
  };

  nativeBuildInputs = [
    nanogpt-api
  ];

  buildPhase = ''
    nanogpt-api --offline-store $src crush-providers > ./crush-providers.json
    nanogpt-api --offline-store $src pi-models > ./pi-models.json
  '';

  installPhase = ''
    mkdir -p $out/share/crush
    cp crush-providers.json $out/share/crush/providers-nanogpt.json

    mkdir -p $out/share/pi
    cp pi-models.json $out/share/pi/models-nanogpt.json
  '';

  passthru = {
    updateScript = updater-tools.requireAll [
      (update-guard.days 2)
      [(lib.getExe (writeShellApplication {
        name = "nanogpt-data-update";
        runtimeInputs = [
          gnused
          nanogpt-api
        ];
        text = ''
          SELF_PATH=$(nix-instantiate --raw --eval -A "$UPDATE_NIX_ATTR_PATH".meta.position)
          PACKAGE_DIR=$(dirname "$SELF_PATH")
          nanogpt-api models > "$PACKAGE_DIR/models.json"
          now=$(date +'%Y-%m-%d')
          slug=0-unstable-
          sed 's/version = "'"$slug"'.*";/version = "'"$slug$now"'";/' \
            -i "$PACKAGE_DIR/package.nix"
        '';
      }))]
    ];
  };

  meta.description = "Model pricing data specific to nano-gpt.com, for use by agent harnesses like Crush or Pi";
})
