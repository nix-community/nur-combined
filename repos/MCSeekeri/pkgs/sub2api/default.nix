{
  lib,
  fetchurl,
  buildGoModule,
  go_1_26,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nix-update-script,
  pnpm_10,
  nodejs,
  stdenvNoCC,
}:
let
  version = "0.1.138";
  src = fetchFromGitHub {
    owner = "Wei-Shaw";
    repo = "sub2api";
    rev = "v${version}";
    hash = "sha256-JGk98y/BJoMByL9EEYREx0k5sfiN5N8BaEZ4+ufajUY=";
  };

  go = go_1_26.overrideAttrs (_: rec {
    version = "1.26.4";
    src = fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      hash = "sha256-T2aKMvv8ETLmqIH7lowvHa2mMUkqM5IRc1+7JVpCYC0=";
    };
  });

  frontendPnpmDeps = fetchPnpmDeps {
    pname = "sub2api-frontend";
    inherit version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    sourceRoot = "source/frontend";
    hash = "sha256-Kvh/ROIvKxLrJSz9EyP5IemJnPY9KqW71MGiG6t6F8c=";
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
buildGoModule.override { inherit go; } {
  pname = "sub2api";
  inherit version src;

  modRoot = "backend";
  vendorHash = "sha256-rfv0MEUx2IXf3GsDVVZhEIyvKAW0L68tyzbrP5f4iqk=";

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

  passthru.updateScript = nix-update-script { };

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
