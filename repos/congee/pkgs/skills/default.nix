{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  git,
}:

let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "skills";
  version = "1.5.9";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "skills";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gFEfdT0h9VbC+I0WUcZ9SYSW2A1liCc2An6qkti7+5U=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm;
    fetcherVersion = 3;
    hash = "sha256-3GSa4ze859dRA4Yrxw8r3rwZKn7FMSjBMvpz1HTDobU=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm exec obuild
    find -name 'node_modules' -type d -prune -exec rm -rf {} +
    pnpm install --offline --prod --ignore-scripts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r bin dist package.json README.md ThirdPartyNoticeText.txt node_modules $out/lib/${finalAttrs.pname}/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/skills \
      --prefix PATH : ${lib.makeBinPath [ git ]} \
      --add-flags "$out/lib/${finalAttrs.pname}/bin/cli.mjs"
    makeWrapper ${lib.getExe nodejs} $out/bin/add-skill \
      --prefix PATH : ${lib.makeBinPath [ git ]} \
      --add-flags "$out/lib/${finalAttrs.pname}/bin/cli.mjs"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$(mktemp -d)"
    "$out/bin/skills" --version | head -n1 | grep -F "${finalAttrs.version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "The open agent skills ecosystem";
    homepage = "https://github.com/vercel-labs/skills";
    downloadPage = "https://www.npmjs.com/package/skills";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "skills";
  };
})
