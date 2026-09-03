{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "dnspick";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "palemoky";
    repo = "dnspick";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Rv2e7oQMul2Ew8ELLRlF06tokYc/gRKJ7DqC4lok/p0=";
  };

  vendorHash = "sha256-dIgeYos0Z9KavqwVyhN9q62WnPPOdEqdz70FuwbznUQ=";

  ldflags =
    let
      buildinfoPkg = "github.com/palemoky/dnspick/internal/buildinfo";
    in
    [
      "-s"
      "-w"
      "-X ${buildinfoPkg}.Version=v${finalAttrs.version}"
      "-X ${buildinfoPkg}.Commit=v${finalAttrs.version}"
      "-X ${buildinfoPkg}.Date=unknown"
    ];

  # Tests probe real DNS servers and need network access.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform DNS benchmark CLI";
    homepage = "https://github.com/palemoky/dnspick";
    changelog = "https://github.com/palemoky/dnspick/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "dnspick";
    platforms = lib.platforms.unix;
  };
})
