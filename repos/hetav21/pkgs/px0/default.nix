{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nodejs,
  git,
  makeWrapper,
  nix-update-script,
}:

buildGoModule rec {
  pname = "px0";
  version = "0.1.16";

  src = fetchFromGitHub {
    owner = "px0-ai";
    repo = "px0";
    rev = "v${version}";
    hash = "sha256-fMV7V80CmgsGO/dL4xbEEtUBYpVBNxDCKyqy574w2KQ=";
  };

  vendorHash = "sha256-71+6I0u3en/Aw3PVMXx6dF+NQtCiE1T+kd7MENCKnlk=";

  nativeBuildInputs = [
    nodejs
    makeWrapper
  ];

  nativeCheckInputs = [ git ];

  preBuild = ''
    node ./scripts/build-web.js
  '';

  postInstall = ''
    wrapProgram $out/bin/px0 \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  # TestStaticAssetServing requires internet access to download vendor assets from CDN
  checkFlags = [
    "-skip"
    "TestStaticAssetServing"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "IDE built for reviewing AI-generated code, optimized for speed";
    homepage = "https://github.com/px0-ai/px0";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "px0";
  };
}
