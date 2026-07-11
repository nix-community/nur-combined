{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatch-vcs,
  hatchling,
  nodejs,
  nodejs-slim_latest,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nix-update-script,
}:

let
  pnpm' = pnpm_11.override {
    nodejs-slim = nodejs-slim_latest;
  };
in
buildPythonPackage rec {
  pname = "yt-dlp-ejs";
  version = "0.8.0-unstable-2026-06-20";
  pyproject = true;

  # needed because setuptools-scm doesn't like the 0-unstable format
  env.SETUPTOOLS_SCM_PRETEND_VERSION = builtins.elemAt (builtins.split "-" version) 0;

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "ejs";
    rev = "6f8587bb7009a1fc81038538071d2cb66b8b8ed0";
    hash = "sha256-Zs2b9nNeJmZW2Sdbmll2sqUjk/s2LWyeedSep0HL590=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;
    fetcherVersion = 4;
    pnpm = pnpm';
    hash = "sha256-NeTpc5pyf38dbWBLGuAJ7YVjXFI31h7CSIApjdNJ57c=";
  };

  build-system = [
    hatch-vcs
    hatchling
  ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm'
  ];

  pythonImportsCheck = [ "yt_dlp_ejs" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--version=branch=main"
      pname
    ];
  };

  meta = {
    description = "External JavaScript for yt-dlp supporting many runtimes";
    license = with lib.licenses; [
      unlicense
      mit
      isc
    ];
    homepage = "https://github.com/yt-dlp/ejs/";
    changelog = "https://github.com/yt-dlp/ejs/commits/${src.rev}";
  };
}
