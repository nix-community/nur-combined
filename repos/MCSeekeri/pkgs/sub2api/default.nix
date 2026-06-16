{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_9,
  pnpmConfigHook,
  nodejs,
  stdenvNoCC,
}:
let
  version = "0.1.136";
  src = fetchFromGitHub {
    owner = "Wei-Shaw";
    repo = "sub2api";
    rev = "v${version}";
    hash = "sha256-yzEHmf8JcN42tfZDkwBb1A7MQ66K6JQZwisiv2hH1WE=";
  };

  frontend = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "sub2api-frontend";
    inherit version;
    inherit src;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_9;
      fetcherVersion = 3;
      sourceRoot = "source/frontend";
      hash = "sha256-r/v/se0eyK3gNYuMiJ0pCijOdhAcaSYHD80DzSzR9sw=";
    };
    pnpmRoot = "frontend";

    nativeBuildInputs = [
      nodejs
      pnpm_9
      pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      cd frontend
      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -r ../backend/internal/web/dist/. "$out/"

      runHook postInstall
    '';
  });
in
buildGoModule (finalAttrs: {
  pname = "sub2api";
  inherit version;

  inherit src;

  modRoot = "backend";
  vendorHash = "";

  postPatch = ''
    rm -rf backend/internal/web/dist
    mkdir -p backend/internal/web/dist
    cp -r ${frontend}/. backend/internal/web/dist/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.Commit=${finalAttrs.src.rev or "unknown"}"
    "-X main.Date=1970-01-01T00:00:00Z"
    "-X main.BuildType=release"
  ];

  tags = [ "embed" ];
  subPackages = [ "cmd/server" ];

  meta = {
    description = "AI API Gateway Platform for Subscription Quota Distribution";
    homepage = "https://github.com/Wei-Shaw/sub2api";
    changelog = "https://github.com/Wei-Shaw/sub2api/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "server";
    platforms = lib.platforms.linux;
  };
})
