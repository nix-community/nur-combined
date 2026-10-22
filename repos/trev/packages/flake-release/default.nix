{
  buildGoModule,
  fetchFromGitea,
  lib,
  nix-update-script,
  pkg-config,
  xz,
}:

buildGoModule (final: {
  pname = "flake-release";
  version = "0.41.3";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-KvfaBnFp3AM4K2CesNfP8ARqa7a87OAnN0c4Fa+UWRo=";
  };

  vendorHash = "sha256-UQjNOV8GOcH4b5ZVqlCRrL0iO7f9zRUYQuq3pte0dAg=";

  tags = [ "containers_image_openpgp" ];

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    xz.dev
    xz.out
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      final.pname
    ];
  };

  meta = {
    mainProgram = "flake-release";
    description = "Flake package releaser";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    homepage = "https://trev.zip/llc/flake-release";
    changelog = "https://trev.zip/llc/flake-release/releases/tag/v${final.version}";
  };
})
