{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "panix";
  version = "0.8.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "mihakrumpestar";
    repo = "panix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SpI4ftYuOG0+YV3AR592O9vYqH4klNVpiU0CiyLMktQ=";
  };

  subPackages = [ "cmd/panix" ];

  flags = [ "-trimpath" ];
  ldflags = [
    "-s"
    "-w"
  ];

  env.CGO_ENABLED = 0;

  vendorHash = "sha256-Ltftb6r6w/F1eXu3KZd0rMHwdKl5wzMPlLd0bg72Pds=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Universal NixOS Deployment Tool - inspect, bootstrap, build, transfer, secrets, activate, rollback";
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
