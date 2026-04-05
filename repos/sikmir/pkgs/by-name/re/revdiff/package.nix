{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "revdiff";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "revdiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fZt3zEX6Sv2iAQuRlbrdJPNuoGvDwO4e5XsFDoXv9qQ=";
  };

  vendorHash = null;

  ldflags = [
    "-s -w"
    "-X main.revision=v${finalAttrs.version}"
  ];

  doCheck = false;

  meta = {
    description = "TUI for reviewing git diffs with inline annotations";
    homepage = "https://github.com/umputun/revdiff";
    maintainers = with lib.maintainers; [ sikmir ];
    license = lib.licenses.mit;
    mainProgram = "revdiff";
  };
})
