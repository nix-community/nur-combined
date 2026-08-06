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
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "wojtekmach";
    repo = "req";
    rev = "v${version}";
    hash = "sha256-2qFACiSgxUf0A5fzBjPI4ARg5ryBuM4pNGSNdy0y5og=";
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
