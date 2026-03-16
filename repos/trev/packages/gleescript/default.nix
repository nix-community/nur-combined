{
  fetchFromGitHub,
  gleam,
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

  gleamDeps = gleam.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Jh6yV6Spr2eqhtGfldCostrkK3NSmqgynzkwpVlgImc=";
  };

  nativeBuildInputs = [
    gleam.erlangHook
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Bundles your Gleam-on-Erlang project into an escript";
    mainProgram = "gleescript";
    homepage = "https://github.com/lpil/gleescript";
    changelog = "https://github.com/lpil/gleescript/releases/tag/v${finalAttrs.version}";
    platforms = lib.platforms.all;
  };
})
