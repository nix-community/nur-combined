{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
}:

let
  version = "4.1.1";

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
    fetcherVersion = 4;
    hash = "sha256-5WXLKMcI6MWM+pjXIIX1cmVluIsX0FUZnFNfvCW5rFY=";
  };

  nativeBuildInputs = [
    pnpm
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
