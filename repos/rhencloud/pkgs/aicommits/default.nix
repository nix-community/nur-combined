{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pnpm_10 ? null,
  pnpmConfigHook,
  fetchPnpmDeps,
}:

let
  version = "4.1.1";

  pnpm' = if pnpm_10 != null then pnpm_10 else pnpm;

  src = fetchFromGitHub {
    owner = "nutlope";
    repo = "aicommits";
    rev = "v${version}";
    hash = "sha256-W3+nXPJm5sCBozM3ZhreD9AQql8y+L+qe34JWe8Volo=";
  };
in
stdenv.mkDerivation {
  pname = "aicommits";
  inherit version src;

  pnpmDeps = fetchPnpmDeps {
    pname = "aicommits-pnpm-deps";
    inherit version src;
    pnpm = pnpm';
    fetcherVersion = 3;
    hash = "sha256-wDJ9unTtRX0Mwigm+zMibScyFM9oUmVYuIz5esSya/A=";
  };

  nativeBuildInputs = [
    pnpm'
    pnpmConfigHook
    nodejs
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r dist $out/
    ln -s $out/dist/cli.mjs $out/bin/aicommits
    ln -s $out/dist/cli.mjs $out/bin/aic
    runHook postInstall
  '';

  meta = {
    description = "A CLI that writes your git commit messages for you with AI";
    homepage = "https://github.com/nutlope/aicommits";
    license = lib.licenses.mit;
    mainProgram = "aicommits";
    platforms = lib.platforms.linux;
  };
}
