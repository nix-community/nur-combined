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
  version = "0.8.0-unstable-2026-10-26";
  pyproject = true;

  # needed because setuptools-scm doesn't like the 0-unstable format
  env.SETUPTOOLS_SCM_PRETEND_VERSION = builtins.elemAt (builtins.split "-" version) 0;

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "ejs";
    rev = "d48c6303a5a6455a42ef9e0b445149cadea51279";
    hash = "sha256-CziuuOFTRHWx68oejRZ0gYgATMbgzY06cslt7qQ81KM=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;
    fetcherVersion = 4;
    pnpm = pnpm_11;
    hash = "sha256-NeTpc5pyf38dbWBLGuAJ7YVjXFI31h7CSIApjdNJ57c=";
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
