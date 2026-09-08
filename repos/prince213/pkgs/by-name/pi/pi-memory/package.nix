{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pi-memory";
  version = "0.4.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "jayzeng";
    repo = "pi-memory";
    tag = "v${finalAttrs.version}";
    hash = "sha256-20hbBZ3loTvpun+CTUp2dRU77eKtSw4J2bS8rvsRGgM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp index.ts package.json $out

    runHook postInstall
  '';

  meta = {
    description = "Persistent memory extension for the Pi coding agent";
    homepage = "https://github.com/jayzeng/pi-memory";
    downloadPage = "https://github.com/jayzeng/pi-memory/tags";
    changelog = "https://github.com/jayzeng/pi-memory/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
