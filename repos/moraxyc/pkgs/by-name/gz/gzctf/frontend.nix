{
  stdenvNoCC,
  fetchurl,
  replaceVars,

  pname,
  version,
  src,
  preBuild,

  nodejs,
  pnpm_10,
  pnpm ? pnpm_10,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "${pname}-frontend";

  inherit version src preBuild;

  patches = [
    (replaceVars ./0001-Use-local-file-to-provide-contributors.patch {
      CONTRIBUTORS_JSON = finalAttrs.passthru.contributors;
    })
    ./0002-Do-not-use-webfont-dl.patch
  ];

  sourceRoot = "${finalAttrs.src.name}/src/GZCTF/ClientApp";

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      patches
      ;
    fetcherVersion = 2;
    hash = "sha256-mg5BybafGgTIsJqRpXE1XpLxtMBuHAwY6ZGN9BqAxGk=";
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
  passthru = {
    contributors = fetchurl {
      url = "https://api.github.com/repos/GZTimeWalker/GZCTF/contributors";
      hash = "sha256-Y8stZF+F5UW50oY0QrhuDSnCKKl7m7omvaFHgFAAqjg=";
    };
  };
})
