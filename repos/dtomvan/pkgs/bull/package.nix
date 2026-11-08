{
  pkgs,
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  withCodemirror ? false,
  withMermaid ? false,
}:

buildGoModule (finalAttrs: {
  pname = "bull";
  version = "0-unstable-2026-08-27";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "gokrazy";
    repo = "bull";
    rev = "8deb93becfa9e7ce99709a6d9f923d1201e10e5e";
    hash = "sha256-hBerV2vnI6u/mAVAuM83ALzHfpYLZeZrIT2sj0BxyTo=";
  };

  vendorHash = "sha256-dSD/b+M36Lh+V+m3VKuIK+ocBimWyG4cLFq5IXRe0Wk=";

  env.CGO_ENABLED = "0";

  ldflags = [ "-s" ];

  tags = lib.optional (!withCodemirror) "nocodemirror" ++ lib.optional (!withMermaid) "nomermaid";

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    services.default = {
      imports = lib.singleton (lib.modules.importApply ./service.nix { inherit pkgs; });
      bull.package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Minimalist bullet journaling program";
    homepage = "https://github.com/gokrazy/bull";
    license = with lib.licenses; [
      bsd0
      mit
    ];
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "bull";
  };
})
