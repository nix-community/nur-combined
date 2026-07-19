{
  lib,
  sources,
  buildGoModule,
  versionCheckHook,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  stdenv,
}:
let
  frontendPnpmDeps = fetchPnpmDeps {
    pname = "${sources.axonhub.pname}-frontend-pnpm-deps";
    inherit (sources.axonhub) version src;
    sourceRoot = "source/frontend";
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-upGbYP9oRsGaMjgWsVnoWxdm2EO4pqZEr5cFyE+MYSg=";
  };

  frontendDist = stdenv.mkDerivation {
    pname = "${sources.axonhub.pname}-frontend-dist";
    inherit (sources.axonhub) version src;
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
  inherit (sources.axonhub) pname version src;
  vendorHash = "sha256-Yx1dY4as3ICRts9GuA4UEFM0p68fHtTHlee5mfSCiq4=";

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

  meta = {
    changelog = "https://github.com/looplj/axonhub/releases/tag/v${finalAttrs.version}";
    mainProgram = "axonhub";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Open-source AI gateway with built-in failover, load balancing, cost control and end-to-end tracing";
    homepage = "https://github.com/looplj/axonhub";
    license = lib.licenses.asl20;
  };
})
