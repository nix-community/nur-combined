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
  version = "0.9.3-unstable-2026-09-17";
  __structuredAttrs = true;

  src = fetchFromGitHub {
  owner = "mihakrumpestar";
  repo = "panix";
  rev = "13006efaddc3ccf831be78d5b3d9073fa78e27f2";
  hash = "sha256-umYvRmElWprOj+j0yDJvHfgHdt8U/4OSjpVT3+Rfr7Q=";
};

  nativeBuildInputs = [ installShellFiles ];

  subPackages = [ "cmd/panix" ];

  flags = [ "-trimpath" ];
  ldflags = [
    "-s"
    "-w"
  ];

  env.CGO_ENABLED = 0;

  vendorHash = "sha256-c+Qjn/RTZdSOFeqCaANBLaJl3zFeJYe7lIAve35rDkQ=";

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
