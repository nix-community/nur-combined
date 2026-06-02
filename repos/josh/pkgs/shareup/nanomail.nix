{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  deno,
  makeWrapper,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "nanomail";
  version = "0-unstable-2026-03-04";

  src = fetchFromGitHub {
    owner = "shareup";
    repo = "nanomail";
    rev = "b2147d3c8c670bd6f8707b2b5da358bcfaf0efed";
    hash = "sha256-CQoc35cypm2mJX7C9REVj9pkZ7fN6Yd6bAK/oNwl6i8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/nanomail $out/bin
    cp -r . $out/lib/nanomail/
    makeWrapper ${deno}/bin/deno $out/bin/nanomail \
      --add-flags "run" \
      --add-flags "--allow-all" \
      --add-flags "--no-lock" \
      --add-flags "$out/lib/nanomail/main.ts"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A Deno + JXA CLI for reading and managing Apple Mail on macOS";
    homepage = "https://github.com/shareup/nanomail";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "nanomail";
  };
}
