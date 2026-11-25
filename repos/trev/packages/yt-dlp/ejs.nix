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
  version = "0.8.0-unstable-2026-11-25";
  pyproject = true;

  # needed because setuptools-scm doesn't like the 0-unstable format
  env.SETUPTOOLS_SCM_PRETEND_VERSION = builtins.elemAt (builtins.split "-" version) 0;

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "ejs";
    rev = "40b7a7d4aee59853043ab204b6ee0d96ec92c646";
    hash = "sha256-+1Ygb4D9PKI/gUhmq/94qrfU9IP3zGhCQHAMt2XhUZo=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;
    fetcherVersion = 4;
    pnpm = pnpm_11;
    hash = "sha256-wKeModzw11Ppa3ri/o0mdVYj8RrCSyERkoXRwNW6tmw=";
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
