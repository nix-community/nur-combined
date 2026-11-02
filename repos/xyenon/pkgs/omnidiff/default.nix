{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  git,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "omnidiff";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ivankovic";
    repo = "omnidiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UKVsTsWot1EJWU0k2atnomcPDlUEbJl2xk03K+SfNeI=";
  };

  cargoHash = "sha256-XUZPUVamZ/edJueCELqW2+j0Mh4fXUST/VIN2y/17mo=";

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ git ];

  cargoBuildFlags = [
    "--bin"
    "omnidiff"
  ];
  cargoTestFlags = [ "--lib" ];
  # Git tests change the working directory and need separate processes.
  useNextest = true;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/omnidiff util man > omnidiff.1
    installManPage omnidiff.1
    installShellCompletion --cmd omnidiff \
      --bash <($out/bin/omnidiff util completions bash) \
      --zsh <($out/bin/omnidiff util completions zsh) \
      --fish <($out/bin/omnidiff util completions fish)
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, robust, accurate content-aware diffing";
    homepage = "https://github.com/ivankovic/omnidiff";
    changelog = "https://github.com/ivankovic/omnidiff/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "omnidiff";
  };
})
