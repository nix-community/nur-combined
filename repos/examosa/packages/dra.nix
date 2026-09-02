{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  bzip2,
  xz,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dra";
  version = "0.10.3";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "devmatteini";
    repo = "dra";
    tag = finalAttrs.version;
    hash = "sha256-g5YIa4FcVRu/XSnjzQ/l0w0XCHVKlN90ONHfDHh9F7c=";
  };

  cargoHash = "sha256-eQgPHlIFC7m2ylbp9lshJM//Epwest/FR9xsG9dK+Z4=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    bzip2
    xz
  ];

  # all tests either use docker or make network requests
  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd dra \
      --bash <($out/bin/dra completion bash) \
      --fish <($out/bin/dra completion fish) \
      --zsh <($out/bin/dra completion zsh)
  '';

  passthru.updateScript = nix-update-script {extraArgs = ["--use-github-releases"];};

  meta = {
    description = "A command line tool to download release assets from GitHub";
    homepage = "https://github.com/devmatteini/dra";
    changelog = "https://github.com/devmatteini/dra/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "dra";
  };
})
