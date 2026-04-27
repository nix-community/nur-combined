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
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "bwireman";
    repo = "go-over";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eCu64t/iCxNhIdHFUJZ2zS5GZ8JTQx+v4TjNTmyzDP8=";
  };

  gleamDeps = gleamFetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-uxtaVQwL17yQPcK8KggkG/ndeJfjab9W3nF/S7LO/NA=";
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
