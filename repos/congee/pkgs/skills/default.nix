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
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "skills";
    rev = "bc21a37a12b90fcb5aec051c91baf5b227b704b1";
    hash = "sha256-JVJeottMyjxdiGPS7O4QsshKdbwbYcKMvwe/PB7I/Zw=";
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
    hash = "sha256-0CS6BTjTj/TAnMNahTk4Vt/0/2eMxmCGUV9PwI8l4Ao=";
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
