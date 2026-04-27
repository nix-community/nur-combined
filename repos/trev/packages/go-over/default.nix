{
  fetchFromGitHub,
  gleamErlangHook,
  gleamFetchDeps,
  lib,
  nix-update-script,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "go-over";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "bwireman";
    repo = "go-over";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I2r0kKxqWMNSqg/tj23A7eljrW8R5TnGSEX8Ltr7dZA=";
  };

  gleamDeps = gleamFetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-6iZdSexuRcg2IPoPbFLAQ2w3E3s/K92s8wxBoJPwHLM=";
  };

  nativeBuildInputs = [
    gleamErlangHook
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "go_over";
    description = "Audits Erlang & Elixir dependencies";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/bwireman/go-over";
    changelog = "https://github.com/bwireman/go-over/releases/tag/v${finalAttrs.version}";
  };
})
