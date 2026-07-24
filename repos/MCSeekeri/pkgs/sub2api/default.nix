{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nix-update-script,
  pnpm_10,
  nodejs,
  stdenvNoCC,
}:
let
  version = "0.1.164";
  src = fetchFromGitHub {
    owner = "Wei-Shaw";
    repo = "sub2api";
    rev = "v${version}";
    hash = "sha256-4GtFTtKk41yGPCwepCtwDy94Faf4090lPXwTIBiJjew=";
  };

  frontendPnpmDeps = fetchPnpmDeps {
    pname = "sub2api-frontend";
    inherit version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    sourceRoot = "source/frontend";
    hash = "sha256-cXBthLF4suUMlJ4I/R2BvWrf5TnNXMgVcfvzkl4u9BU=";
  };

  frontend = stdenvNoCC.mkDerivation {
    pname = "sub2api-frontend";
    inherit version src;

    sourceRoot = "${src.name}/frontend";

    postPatch = ''
      substituteInPlace vite.config.ts \
        --replace-fail "../backend/internal/web/dist" "dist"
    '';

    pnpmDeps = frontendPnpmDeps;

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r dist/. "$out/"
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "sub2api";
  inherit version src;

  modRoot = "backend";
  vendorHash = "sha256-n2enHZwqmjK5NOdfIYglopI8/qaHjwxSAbbZaiLNkiQ=";
  postPatch = ''
    substituteInPlace backend/go.mod \
      --replace-fail "go 1.26.5" "go 1.26"
    rm -rf backend/internal/web/dist
    mkdir -p backend/internal/web/dist
    cp -r ${frontend}/. backend/internal/web/dist/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.Commit=${src.rev or "unknown"}"
    "-X main.Date=1970-01-01T00:00:00Z"
    "-X main.BuildType=release"
  ];

  tags = [ "embed" ];
  subPackages = [ "cmd/server" ];

  passthru = {
    updateScript = nix-update-script { };
    inherit frontendPnpmDeps;
  };

  meta = {
    description = "AI API Gateway Platform for Subscription Quota Distribution";
    longDescription = ''
      Sub2API is an AI API gateway platform that manages subscription quota distribution
      across multiple upstream providers with user management, API key control, and usage tracking.
    '';
    homepage = "https://github.com/Wei-Shaw/sub2api";
    changelog = "https://github.com/Wei-Shaw/sub2api/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "server";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
}
