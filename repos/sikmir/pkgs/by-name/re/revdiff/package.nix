{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "revdiff";
  version = "1.11.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "revdiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C9mquc0mrdFgKN+6YLQJ35Z4DLKNiBxQa2yXa4HXYkI=";
  };

  vendorHash = null;

  ldflags = [
    "-s -w"
    "-X main.revision=v${finalAttrs.version}"
  ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/{app,revdiff}
  '';

  meta = {
    description = "TUI for reviewing git diffs with inline annotations";
    homepage = "https://github.com/umputun/revdiff";
    maintainers = with lib.maintainers; [ sikmir ];
    license = lib.licenses.mit;
    mainProgram = "revdiff";
  };
})
