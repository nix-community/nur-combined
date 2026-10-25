{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nix-update-script,
  pnpm_12,
  nodejs,
  jq,
  stdenvNoCC,
}:
let
  version = "0.2.18";
  src = fetchFromGitHub {
    owner = "Wei-Shaw";
    repo = "sub2api";
    rev = "v${version}";
    hash = "sha256-ILxtbR7INnR7XWd7Z7osZVjGpwx9cEzcFDMJl7oFQII=";
  };

  pnpmWorkspaceOverrides = ''
    if jq -e '.pnpm.overrides | length > 0' package.json > /dev/null; then
      jq -r '"overrides:", (.pnpm.overrides | to_entries[] | "  \(.key | tojson): \(.value | tojson)")' \
        package.json > pnpm-workspace.yaml
    fi
  '';

  frontendPnpmDeps = fetchPnpmDeps {
    pname = "sub2api-frontend";
    inherit version src;
    pnpm = pnpm_12;
    fetcherVersion = 4;
    sourceRoot = "source/frontend";
    postPatch = pnpmWorkspaceOverrides;
    hash = "sha256-vqWhnCnlaf1i6Dh4n51ICPZhMC6so8rnS/VhqiGveX4=";
  };

  frontend = stdenvNoCC.mkDerivation {
    pname = "sub2api-frontend";
    inherit version src;

    sourceRoot = "${src.name}/frontend";

    postPatch = ''
      substituteInPlace vite.config.ts \
        --replace-fail "../backend/internal/web/dist" "dist"
    ''
    + pnpmWorkspaceOverrides;

    pnpmDeps = frontendPnpmDeps;

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_12
      jq
    ];

    env.NODE_ENV = "production";

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
buildGo127Module {
  pname = "sub2api";
  inherit version src;

  modRoot = "backend";
  vendorHash = "sha256-w/KCiTofYSZGtDo+iDkA2YST1HWsPAu+v2ZGf/1OapM=";
  postPatch = ''
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
    inherit frontendPnpmDeps src;
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
