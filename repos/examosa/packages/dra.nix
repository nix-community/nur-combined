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
  version = "0.10.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "devmatteini";
    repo = "dra";
    tag = finalAttrs.version;
    hash = "sha256-wSJ+Ohd5YdoVBnpxFH4rzFu2rEI84nfKvpu+E+4ca6o=";
  };

  cargoHash = "sha256-d9I0ychu5DsVMQlLQ+zzKkg8Xb6EAkM5+36qRwT2bJM=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    bzip2
    xz
  ];

  # tests require docker
  checkFlags = [
    "--skip=installed_successfully"
    "--skip=upgrade_successfully"
    "--skip=wrong_privileges"
  ];

  postInstall = ''
    installShellCompletion --cmd dra \
      --bash <($out/bin/dra completion bash) \
      --fish <($out/bin/dra completion fish) \
      --zsh <($out/bin/dra completion zsh)
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "A command line tool to download release assets from GitHub";
    homepage = "https://github.com/devmatteini/dra";
    changelog = "https://github.com/devmatteini/dra/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "dra";
  };
})
