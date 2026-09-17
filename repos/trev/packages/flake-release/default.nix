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
  version = "0.26.1";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-RaOBNv0iekA/sOMbVQdrelUYp7lYdy4HLO5TzEgbH5c=";
  };

  vendorHash = "sha256-xMjzT2++xdrXX+x8rcVsZ9/TLPco0fNhSzZbfFsSWvY=";

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
