{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatch-vcs,
  hatchling,
  nodejs,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "yt-dlp-ejs";
  version = "0.8.0-unstable-2026-11-24";
  pyproject = true;

  # needed because setuptools-scm doesn't like the 0-unstable format
  env.SETUPTOOLS_SCM_PRETEND_VERSION = builtins.elemAt (builtins.split "-" version) 0;

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "ejs";
    rev = "181a67bbdf94c095a77359c01b4c372ac6355796";
    hash = "sha256-cfPAq7wDMGoZUMk+b+bLPBbzPmo5evw5TP5hEoSHiOI=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;
    fetcherVersion = 4;
    pnpm = pnpm_11;
    hash = "sha256-7OMCtyI7pLb+5p6wrUApkFEp5t+KvVB8oNL9SWJPW9U=";
  };

  build-system = [
    hatch-vcs
    hatchling
  ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_11
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
