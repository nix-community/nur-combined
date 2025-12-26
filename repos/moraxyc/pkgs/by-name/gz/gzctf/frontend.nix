{
  stdenvNoCC,
  sources,
  replaceVars,

  pname,
  version,
  src,
  preBuild,

  nodejs,
  pnpm_10,
  pnpm ? pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "${pname}-frontend";

  inherit version src preBuild;

  patches = [
    (replaceVars ./0001-Use-local-file-to-provide-contributors.patch {
      CONTRIBUTORS_JSON = sources.gzctf-contributors.src;
    })
    ./0002-Do-not-use-webfont-dl.patch
  ];

  sourceRoot = "${finalAttrs.src.name}/src/GZCTF/ClientApp";

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      patches
      ;
    fetcherVersion = 3;
    hash = "sha256-NYigJd6FveH/S7v8/9C3sJoNVHMeTzL8pRvoSvC+rz8=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r build $out

    runHook postInstall
  '';
})
