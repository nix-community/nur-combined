{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs_20,
  pnpm_9,
  pnpmConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "headscale-webui";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "jamebal";
    repo = "headscale-webui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IDWrGXJG18j4xpDxE/w/wmRrK6wY+ykV4aeshKboK8Q=";
  };

  patches = [ ./pnpm-lock.yaml.patch ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    fetcherVersion = 3;
    hash = "sha256-rwK8+vbs4fdETBzeC/oc3y6nSQ3VcznahdqmedzFgrg=";
  };

  nativeBuildInputs = [
    nodejs_20
    pnpm_9
    pnpmConfigHook
  ];

  buildPhase = ''
    runHook preBuild
    pnpm run build:prod
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -R dist $out
    runHook postInstall
  '';

  meta = {
    description = "Tailscale-compatible orchestration server web front-end for headscale";
    homepage = "https://github.com/jamebal/headscale-webui";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
