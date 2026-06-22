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
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "bwireman";
    repo = "go-over";
    rev = "v${finalAttrs.version}";
    hash = "sha256-egVXAoo3J0yMyCJrfGKOp0V3bmOkMfAiCSoEwo9Lbo4=";
  };

  gleamDeps = gleamFetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-0LS5e9PpbXmRBksgxv7XJ23MEXCOxtVj3tZ0tVjPWas=";
  };

  nativeBuildInputs = [
    gleamErlangHook
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage=gleamDeps"
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
