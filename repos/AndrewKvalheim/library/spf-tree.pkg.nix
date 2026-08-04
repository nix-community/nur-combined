{ buildGoModule
, fetchFromGitHub
, lib
, unstableGitUpdater
}:

let
  inherit (lib) licenses;
in
buildGoModule (spf-tree: {
  pname = "spf-tree";
  version = "0-unstable-2020-12-07";
  meta = {
    description = "Shows the SPF lookups for a mail host as a tree";
    homepage = "https://github.com/ttacon/spf-tree";
    license = licenses.mit;
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "ttacon";
    repo = "spf-tree";
    rev = "5e97905cb84e301956393900b0df5048e906c511";
    hash = "sha256-NkyCI4oILLNnFnZZXuUcgLcQSQrYAtmWMBUn7aTGWl0=";
  };

  sourceRoot = "${spf-tree.src.name}/cmd/spf-tree";

  vendorHash = "sha256-idBXBEepngpHW3XHIraw85V3Vt+a1RHe318Vxi574mM=";
})
