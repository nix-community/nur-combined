{
  go,
  go_1_27,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  lib,
}:
let
  buildGoModuleAtLeast127 = if (lib.versionAtLeast go.version "1.27") then buildGoModule else buildGoModule.override { go = go_1_27; };
in
buildGoModuleAtLeast127 (finalAttrs: {
  pname = "error-pages";
  version = "4.2.5";

  src = fetchFromGitHub {
    owner = "tarampampam";
    repo = "error-pages";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-drG5PBDlnENFUuE8h6rEjPZuI6N/mt0M3mHLx/EVIdg=";
  };

  vendorHash = null;

  env.CGO_ENABLED = "0";
  ldflags = [
    "-s"
    "-w"
    "-X gh.tarampamp.am/error-pages/v4/internal/appmeta.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/builder"
    "cmd/error-pages"
  ];

  postBuild = ''
    static_target=$out/share/error-pages
    mkdir -p $static_target

    "''${GOPATH}/bin/builder" --index --target-dir $static_target
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
      ];
    };
  };

  meta = {
    mainProgram = "error-pages";
    description = "Static error pages generator for HTTP servers";
    homepage = "https://tarampampam.github.io/error-pages";
    changelog = "https://github.com/tarampampam/error-pages/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
