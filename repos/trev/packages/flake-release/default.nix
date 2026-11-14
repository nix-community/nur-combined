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
  version = "0.47.1";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-keN9wrznvYA1sLCK0rFjMRs17lKkwMbTDxSRQdR56is=";
  };

  vendorHash = "sha256-4EJVz1XvcXGHRbSMLDsOBKbTQqM9HXrTo4Un0J13ZRw=";

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
