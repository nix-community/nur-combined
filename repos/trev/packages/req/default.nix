{
  beamPackages,
  fetchFromGitHub,
  finch,
  jason,
  lib,
  mime,
  nix-update-script,
}:

beamPackages.buildMix rec {
  name = "req";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "wojtekmach";
    repo = "req";
    rev = "v${version}";
    hash = "sha256-oGWmXzzlbMcnkKvUpY0y169yUbKXPfISZ+G6cMKvMxU=";
  };

  beamDeps = [
    finch
    jason
    mime
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      name
    ];
  };

  meta = {
    description = "Req is a batteries-included HTTP client for Elixir";
    homepage = "https://github.com/wojtekmach/req";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
