{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatch-vcs,
  hatchling,
  nodejs,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "yt-dlp-ejs";
  version = "0.8.0-unstable-2026-04-07";
  pyproject = true;

  # needed because setuptools-scm doesn't like the 0-unstable format
  env.SETUPTOOLS_SCM_PRETEND_VERSION = builtins.elemAt (builtins.split "-" version) 0;

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "ejs";
    rev = "2231f1fd6e13aa88ee9b3af7a3193a81e07e6a27";
    hash = "sha256-4YfY7mK3u1LbG37gKIzcy1Hx8DujsQ7j5nh4Puy82Eg=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;
    fetcherVersion = 2;
    hash = "sha256-aGjxNMg84yVquyB+Ldn05rfcSRl6fecH/Mcbx6cOADk=";
  };

  build-system = [
    hatch-vcs
    hatchling
  ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
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
    changelog = "https://github.com/yt-dlp/ejs/commits/${src.rev}";
    description = "External JavaScript for yt-dlp supporting many runtimes";
    homepage = "https://github.com/yt-dlp/ejs/";
    license = with lib.licenses; [
      unlicense
      mit
      isc
    ];
  };
}
