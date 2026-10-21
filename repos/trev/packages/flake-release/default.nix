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
  version = "0.41.2";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-0ESdSKO7YFLppNhYpfc1UIYRnXB2g5efuYzcyP8b0xs=";
  };

  vendorHash = "sha256-2m/EtvQ4WFObXKcOP8I0+WO6rYg3sCNC+x8EaPtItEg=";

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
