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
  version = "0.51.0";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "flake-release";
    rev = "v${final.version}";
    hash = "sha256-6P0Ji1A/1n3dRzv3KaVzY11Agce3hPCTcgWhpyjRcXM=";
  };

  vendorHash = "sha256-2CLC/b9yJd+y1kar4vq3tq3MK5+rbBHq/QF5h5sDIJ4=";

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
