{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "dnspick";
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "palemoky";
    repo = "dnspick";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fl+fIHRHJj63DDoVVQe/NTuxTg2nfXCYRAjjnHF9jng=";
  };

  vendorHash = "sha256-8m64ENTOcVYxiudzzS2Cwi8vDrpJ0JZU9ZgovQEAHIQ=";

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
