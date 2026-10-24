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
  version = "0.42.0";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-kTWBXJ0phy4Pcivmb+tJ/D/OEfagW/rl39vf5oU+p84=";
  };

  vendorHash = "sha256-NtM5FSbbJ27ojhea1osBO8/cNkuswqXwQ+gYeVeQcC8=";

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
