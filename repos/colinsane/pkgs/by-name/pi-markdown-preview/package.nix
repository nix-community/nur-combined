{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
  pandoc,
  stdenv,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-markdown-preview";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "omaclaren";
    repo = "pi-markdown-preview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1JLsoQ4/LMekb0yEVp5JAsDMLLAL/KI/T5G4mUw9v/Y=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-NK2VOpkQjvtkbF9LktYujrlY0DRRN3nAbLRiB/MVAMs=";

  propagatedBuildInputs = [
    pandoc
  ];

  dontNpmBuild = true; # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rendered markdown + LaTeX preview for pi, with terminal, browser, and PDF output";
    homepage = "https://github.com/omaclaren/pi-markdown-preview";
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
    broken = stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform != stdenv.buildPlatform; # XXX(2026-11-13): cross is broken by lua
  };
})
