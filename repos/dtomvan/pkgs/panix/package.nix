{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchpatch,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "panix";
  version = "0.9.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "mihakrumpestar";
    repo = "panix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4bbFpHqjQbBReUm7qV2MRJJfh0nsU7ssHofpoP7eqS8=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/mihakrumpestar/panix/commit/c50512b25589bcc30a8682f543d688a75e1bc556.patch";
      hash = "sha256-dwvx58GY9I4EhNiml6BquEb/CxbwR5owpMBGpzb2tWM=";
    })
  ];

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
