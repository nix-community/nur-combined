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
  version = "1.0.0-beta9";

  src = fetchFromGitHub {
    owner = "looplj";
    repo = "axonhub";
    tag = "v${version}";
    hash = "sha256-1M8btjZ8HeTJ0EjrzvCOuKrNtiSFI+1TZGvXK6AMomA=";
  };

  frontendPnpmDeps = fetchPnpmDeps {
    pname = "axonhub-frontend-pnpm-deps";
    inherit version src;
    sourceRoot = "source/frontend";
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-upGbYP9oRsGaMjgWsVnoWxdm2EO4pqZEr5cFyE+MYSg=";
  };

  frontendDist = stdenv.mkDerivation {
    pname = "axonhub-frontend-dist";
    inherit version src;
    sourceRoot = "source/frontend";
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
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  };
in
buildGoModule (finalAttrs: {
  pname = "axonhub";
  inherit version src;
  vendorHash = "sha256-Juge/qz/+5ImNJBpK5tT/uNkKmhftjesnnaBfUpnJYM=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "unstable"
    ];
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
