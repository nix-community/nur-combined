{
  fetchFromGitHub,
  gleamErlangHook,
  gleamFetchDeps,
  lib,
  nix-update-script,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gleescript";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "lpil";
    repo = "gleescript";
    rev = "v${finalAttrs.version}";
    hash = "sha256-thKcoHYPM4/5oukpKIPIp8Q7HnhM6cvmBVWwWqmFnCg=";
  };

  gleamDeps = gleamFetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Jh6yV6Spr2eqhtGfldCostrkK3NSmqgynzkwpVlgImc=";
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
    mainProgram = "gleescript";
    description = "Bundles your Gleam-on-Erlang project into an escript";
    platforms = lib.platforms.all;
    homepage = "https://github.com/lpil/gleescript";
    changelog = "https://github.com/lpil/gleescript/releases/tag/v${finalAttrs.version}";
  };
})
