{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  stdenv,
}:
let
  version = "1.0.0-rc2";

  src = fetchFromGitHub {
    owner = "looplj";
    repo = "axonhub";
    tag = "v${version}";
    hash = "sha256-EVJribtcR3QR2eZWnjmVuFv0YYXQO6cvMFlzTJ41sUY=";
  };

  frontendPnpmDeps = fetchPnpmDeps {
    pname = "axonhub-frontend-pnpm-deps";
    inherit version src;
    sourceRoot = "source/frontend";
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-cv00YAtncpv2oB6mgqMY7DU03Ilct4J78KEJDkLFYI8=";
  };

  frontendDist = stdenv.mkDerivation {
    pname = "axonhub-frontend-dist";
    inherit version src;
    sourceRoot = "source/frontend";
    pnpmDeps = frontendPnpmDeps;
    env.SWC_NATIVE_BINDING_CACHE_SKIP_SECURITY_CHECK = "1";
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
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  };
in
buildGoModule (finalAttrs: {
  pname = "axonhub";
  inherit version src;
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-xD+nto7Z3mWTvlKx96w+Lc+e5938sOlIlzxSGiK3gHw=";

  tags = [ "nomsgpack" ];

  proxyVendor = true;

  preBuild = ''

    rm -rf internal/server/static/dist
    mkdir -p internal/server/static/dist
    cp -r ${frontendDist}/* internal/server/static/dist/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/looplj/axonhub/internal/build.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/axonhub" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "version";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "unstable"
      ];
    };
    # nix-update reads dependency hashes from attributes of the top-level
    # package (pkg.pnpmDeps.outputHash); without this passthru the pnpm
    # fetcher hash in the let binding is invisible to nix-update and goes
    # stale on version bumps.
    pnpmDeps = frontendPnpmDeps;
  };
  meta = {
    changelog = "https://github.com/looplj/axonhub/releases/tag/v${finalAttrs.version}";
    mainProgram = "axonhub";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Open-source AI gateway with built-in failover, load balancing, cost control and end-to-end tracing";
    homepage = "https://github.com/looplj/axonhub";
    license = lib.licenses.asl20;
  };
})
