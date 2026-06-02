{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  deno,
  makeWrapper,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "nanotes";
  version = "0-unstable-2026-03-04";

  src = fetchFromGitHub {
    owner = "shareup";
    repo = "nanotes";
    rev = "0b0434f6659a076cfdbb612c45d41f077b0dbb32";
    hash = "sha256-zLBwol23ubdpIHSRTmLeRPPCHT/9Y9+pyCZ7nt8+YZA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/nanotes $out/bin
    cp -r . $out/lib/nanotes/
    makeWrapper ${deno}/bin/deno $out/bin/nanotes \
      --add-flags "run" \
      --add-flags "--allow-all" \
      --add-flags "--no-lock" \
      --add-flags "$out/lib/nanotes/main.ts"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A standalone CLI for reading and creating notes in Apple Notes";
    homepage = "https://github.com/shareup/nanotes";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "nanotes";
  };
}
