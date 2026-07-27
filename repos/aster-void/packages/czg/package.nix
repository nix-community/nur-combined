{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "czg";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "Zhengqbbb";
    repo = "cz-git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8qYZ9Dc35AsfW4k6c0JNap2G9uLBY8Uw/TXqzo9GnoI=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-wdXuKjsx3rAiftOHCYvpl3uQDFrJwAyzTm0t+30UeLM=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/czg $out/bin
    cp -r packages/cli/lib packages/cli/bin packages/cli/package.json $out/libexec/czg/

    # Create node_modules structure for cz-git dependency
    mkdir -p $out/libexec/czg/node_modules/cz-git
    cp -r packages/cz-git/lib packages/cz-git/package.json $out/libexec/czg/node_modules/cz-git/

    makeWrapper ${lib.getExe nodejs} $out/bin/czg \
      --add-flags "$out/libexec/czg/bin/index.js"

    makeWrapper ${lib.getExe nodejs} $out/bin/git-czg \
      --add-flags "$out/libexec/czg/bin/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Interactive Commitizen CLI that generates standardized git commit messages";
    homepage = "https://github.com/Zhengqbbb/cz-git";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "czg";
  };
})
