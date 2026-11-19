{
  buildGoModule,
  fetchFromGitea,
  lib,
  makeWrapper,
  nix-update-script,
  patchelf,
  pkg-config,
  xz,
}:

buildGoModule (final: {
  pname = "flake-release";
  version = "0.48.2";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-oXj6qoUXPgrYPhPlQCt+z0Km4zhUGibjtvdv4fRb930=";
  };

  vendorHash = "sha256-WKNT6qRW8XxrDJ+DDmYwg5oAeiMIxqOILpG54Se3rM0=";

  tags = [ "containers_image_openpgp" ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];
  buildInputs = [
    xz.dev
    xz.out
  ];

  postInstall = ''
    wrapProgram $out/bin/flake-release --prefix PATH : ${lib.makeBinPath [ patchelf ]}
  '';

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
