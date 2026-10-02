{
  lib,
  fetchFromGitHub,
  bashNonInteractive,
  installShellFiles,
  nix-update-script,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pb";
  version = "1.3.3";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "xwmx";
    repo = "pb";
    tag = finalAttrs.version;
    hash = "sha256-cQ7U59PRhA/B255Yq9H/qM6SLfNtI+2iNhpeM3Y9gSQ=";
  };

  buildInputs = [bashNonInteractive];

  nativeBuildInputs = [installShellFiles];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    installBin pb

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "A tiny wrapper combining pbcopy & pbpaste in a single command";
    homepage = "https://github.com/xwmx/pb";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.examosa];
    mainProgram = "pb";
    platforms = lib.platforms.darwin;
  };
})
