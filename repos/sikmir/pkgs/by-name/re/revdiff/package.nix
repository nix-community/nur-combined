{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "revdiff";
  version = "1.3.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "revdiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lcqkvQ5jLP3sA9WeFcp1PRPIvtq7vWjl7M+9juBYXL0=";
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
