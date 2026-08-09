{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "panix";
  version = "0.9.0-unstable-2026-08-09";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "mihakrumpestar";
    repo = "panix";
    rev = "323a8f82a58c1347afc4cc45a4bd54ac2f2d9509";
    hash = "sha256-vpdO5fBYQ+OhXiMMkjjWmF/dxhxa8D9ulAmsSA43k6Q=";
  };

  nativeBuildInputs = [ installShellFiles ];

  subPackages = [ "cmd/panix" ];

  flags = [ "-trimpath" ];
  ldflags = [
    "-s"
    "-w"
  ];

  env.CGO_ENABLED = 0;

  vendorHash = "sha256-q9pUwV9JGYNIDTemgu28eG2SBH2mNQ2BQO/u73f42xM=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # using process substitution
    installShellCompletion --cmd panix \
      --bash <($out/bin/panix completion -c bash) \
      --fish <($out/bin/panix completion -c fish) \
      --zsh <($out/bin/panix completion -c zsh)
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Universal Nix deployment tool";
    homepage = "https://github.com/mihakrumpestar/panix";
    changelog = "https://github.com/mihakrumpestar/panix/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      dtomvan
      # TODO: add to nixpkgs?
      {
        name = "Miha Krumpestar";
        github = "mihakrumpestar";
        githubId = 70652456;
      }
    ];
    mainProgram = "panix";
  };
})
