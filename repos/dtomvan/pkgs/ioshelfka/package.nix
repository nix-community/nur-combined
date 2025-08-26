{
  lib,
  fetchFromGitHub,
  stdenv,
  iosevka,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  remarshal,
  ttfautohint-nox,
  nerd-font-patcher,
  parallel,
}:
let
  distName = "IoshelfkaMono";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ioshelfka";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "NotAShelf";
    repo = "Ioshelfka";
    rev = "v${finalAttrs.version}";
    hash = "sha256-grVnIBwoWv29q8ayes9dl3aNEV7CVph4GGRx4DudfMM=";
  };

  npmDeps = fetchNpmDeps {
    src = "${iosevka.src}";
    hash = iosevka.npmDepsHash;
  };

  npmRoot = "iosevka";

  postPatch = ''
    cp -r ${iosevka.src} $npmRoot
    chmod -R +w $npmRoot
    cp plans/mono.toml $npmRoot/private-build-plans.toml
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    remarshal
    ttfautohint-nox
    nerd-font-patcher
    parallel
  ];

  buildPhase = ''
    runHook preBuild

    pushd $npmRoot
      npm run build -- ttf::${distName} --jCmd=$NIX_BUILD_CORES
      ls -1 dist/${distName}/TTF/*.ttf \
        | parallel --jobs=$NIX_BUILD_CORES nerd-font-patcher {} --complete --no-progressbars
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd $npmRoot
      for font in *.ttf; do
        install -Dm444 "$font" -t $out/share/fonts/truetype
      done
    popd

    runHook postInstall
  '';

  meta = {
    description = "Home-baked Iosevka builds, with Nix";
    homepage = "https://github.com/NotAShelf/Ioshelfka";
    license = lib.licenses.mit;
    mainProgram = "ioshelfka";
    platforms = lib.platforms.all;
  };
})
