{
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "error-pages";
  version = "4.2.4";

  src = fetchFromGitHub {
    owner = "tarampampam";
    repo = "error-pages";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Z55w5py1UueUW4NKsIdsMjreAy1QT7dRALc8HQ2eVYc=";
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
    updateScript = nix-update-script { };
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
