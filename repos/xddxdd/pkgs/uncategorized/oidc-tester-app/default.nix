{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-09-21";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "4cc6f5412a08bb98ace7c2629b6a0d67406e36b5";
    hash = "sha256-B+90dZf4cJG5SAnJhxeLRiA2hRkeqDI1nFt6/TZrDQM=";
  };
  vendorHash = "sha256-/cLusGRFKwSte/iHWmKwdC6stY3ITHvKPv9ughn+YCQ=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenID Connect relying party web application for testing OIDC providers such as Authelia";
    homepage = "https://github.com/authelia/oidc-tester-app";
    license = lib.licenses.mit;
    mainProgram = "oidc-tester-app";
  };
})
