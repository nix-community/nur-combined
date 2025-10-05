{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_20,
  pnpm_9,
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

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    hash = "sha256-2aERyYmvkRh9A8rCTYRcNccn7431+02amu5a/VMwKt4=";
  };

  nativeBuildInputs = [
    nodejs_20
    pnpm_9.configHook
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
