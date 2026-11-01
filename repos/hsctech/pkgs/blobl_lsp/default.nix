{
  lib,
  buildGo127Module,
  fetchFromCodeberg,
  nix-update-script,
}:

# buildGo127Module: default `go` (1.26) is older than go.mod's `go 1.27.1`.
buildGo127Module (finalAttrs: {
  pname = "blobl_lsp";
  version = "0.8.0";

  src = fetchFromCodeberg {
    owner = "hsctech";
    repo = "blobl_lsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-waGr9QVOFpQyuD/w8/i/xOZa5O3LQ1g0tetVZOil488=";
  };

  __structuredAttrs = true;

  # v0.8.0 depends on blobl_sitter's cgo binding and go-tree-sitter;
  # `go mod vendor` prunes their non-Go files (src/parser.c, tree_sitter/
  # headers), so serve the modules as a proxy instead (same fix as
  # nixpkgs' vale).
  proxyVendor = true;
  vendorHash = "sha256-53fm5SRnHa2+OGclh/tQzremPqJbNN0/uKy6WbrrWTs=";

  passthru.updateScript = nix-update-script { };

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Language server for Bento's Bloblang mapping language";
    homepage = "https://codeberg.org/hsctech/blobl_lsp";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "hsctech";
        email = "henrik@hsctech.eu";
      }
    ];
    mainProgram = "blobl_lsp";
    platforms = lib.platforms.all;
  };
})
