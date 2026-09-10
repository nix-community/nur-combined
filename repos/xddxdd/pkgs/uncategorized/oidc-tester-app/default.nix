{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-09-10";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "eb3b281ccd72d37f18a9e25335f572e36c7edba7";
    hash = "sha256-aj/R90Iv2Y3Y/xZo1kFwT33unTd5nIvKsp9FrNOwfH8=";
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
