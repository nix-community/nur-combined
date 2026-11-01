{
  lib,
  buildGo127Module,
  fetchFromCodeberg,
  nix-update-script,
}:

let
  # blobl_dbg's go.mod carries filesystem `replace` directives to sibling
  # checkouts (bento fork, blobl_lsp, blobl_sitter). postPatch materializes
  # those siblings from fetched sources so the tagged release tarball builds
  # standalone.
  blobl_lsp_src = fetchFromCodeberg {
    owner = "hsctech";
    repo = "blobl_lsp";
    tag = "v0.8.0"; # first tag with the bloblsrc package
    hash = "sha256-waGr9QVOFpQyuD/w8/i/xOZa5O3LQ1g0tetVZOil488=";
  };
  blobl_sitter_src = fetchFromCodeberg {
    owner = "hsctech";
    repo = "blobl_sitter";
    rev = "81d932c9d8a37059bfff62f1215a6be25e688d23"; # main, post-v0.2.4
    hash = "sha256-4gjD9qqM6MuyjQ7VZeCm/pVAnyhh5MBITpo6DWwt/eg=";
  };
  # The bento fork keeps the upstream module path
  # (github.com/warpstreamlabs/bento); the debug hook lives on the
  # blobl-debug branch.
  bento_fork_src = fetchFromCodeberg {
    owner = "hsctech";
    repo = "bento";
    rev = "70a2c1b6243a6be35bc46f95d5c4b013daad207f"; # blobl-debug
    hash = "sha256-bxWJV9H9xEyXsmWkvb36z2daOeeLg09cbI6qQwz8jlE=";
  };
in
# buildGo127Module: default `go` (1.26) is older than go.mod's `go 1.27.3`.
buildGo127Module (finalAttrs: {
  pname = "blobl_dbg";
  version = "0.0.4";

  src = fetchFromCodeberg {
    owner = "hsctech";
    repo = "blobl_dbg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kn35Bae5r621VaGPqPGneJCO0PO8AeAzBMGzyNOyqBQ=";
  };

  __structuredAttrs = true;

  # Keep go.mod's filesystem replaces (`=> ../blobl_lsp` etc.) intact and
  # materialize the sibling checkouts they point at, so vendor/modules.txt
  # records only relative paths (a fixed-output derivation's output must not
  # reference store paths).
  postPatch = ''
    cp -r ${blobl_lsp_src} ../blobl_lsp
    cp -r ${blobl_sitter_src} ../blobl_sitter
    cp -r ${bento_fork_src} ../bento
    chmod -R u+w ../blobl_lsp ../blobl_sitter ../bento
  '';

  vendorHash = "sha256-No3tIuc7eVxssRVRpja8e1yBouy8fWcp/WB86LfV+to=";

  passthru.updateScript = nix-update-script { };

  subPackages = [ "cmd/blobl-dbg" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Interactive debugger for Bento's Bloblang mapping language";
    homepage = "https://codeberg.org/hsctech/blobl_dbg";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "hsctech";
        email = "henrik@hsctech.eu";
      }
    ];
    mainProgram = "blobl-dbg";
    platforms = lib.platforms.all;
  };
})
