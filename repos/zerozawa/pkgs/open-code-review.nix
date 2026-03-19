{
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  makeWrapper,
  nodejs_20,
  pnpm_9,
  pnpmConfigHook,
  stdenvNoCC,
}:
let
  pname = "open-code-review";
  version = "1.8.4";

  src = fetchFromGitHub {
    owner = "spencermarx";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-1bquZYsM4+OPFcs1qkXuXgKFCB2zE1FVtgXMFXM/Kvw=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_9;
    fetcherVersion = 3;
    hash = "sha256-b7MSyps0l5BZLc2deEheA2fFpRZQhIDMebUK1D1x15A=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src pnpmDeps;

  nativeBuildInputs = [
    makeWrapper
    nodejs_20
    pnpm_9
    pnpmConfigHook
  ];

  env.CI = "1";

  buildPhase = ''
    runHook preBuild

    pnpm build:cli

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    local packageOut="$out/lib/node_modules/${pname}"

    mkdir -p "$out/bin"
    mkdir -p "$packageOut/packages"

    cp package.json pnpm-lock.yaml pnpm-workspace.yaml "$packageOut"/
    cp -a node_modules "$packageOut"/
    cp -a packages/cli "$packageOut/packages/"
    cp -a packages/agents "$packageOut/packages/"
    cp -a packages/dashboard "$packageOut/packages/"
    rm -f "$packageOut/node_modules/.modules.yaml"

    makeWrapper ${lib.getExe nodejs_20} "$out/bin/ocr" \
      --add-flags "$packageOut/packages/cli/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Customizable multi-agent code review CLI with web dashboard";
    homepage = "https://github.com/spencermarx/open-code-review";
    license = with licenses; [asl20];
    mainProgram = "ocr";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [fromSource];
  };
}