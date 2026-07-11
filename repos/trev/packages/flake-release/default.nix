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
  version = "0.20.3";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-/URCjiwic1veFzat143MRqcPwFjFcmTZx+DkyY0C18I=";
  };

  vendorHash = "sha256-N2DsX/20npLzdpPMZMgz4vm61hInCVHoGE/kXeRoofA=";

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
