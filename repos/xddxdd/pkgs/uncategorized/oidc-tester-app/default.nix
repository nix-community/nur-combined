{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-09-02";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "8a9d3baefbb626c4f5c8e48a89fc4d09aa4b22e0";
    hash = "sha256-1wbGsQmYmuVClZCy48A5jXCjqMfO6azGaw80qKvpSBc=";
  };
  vendorHash = "sha256-LCB6A02MYDf8V5pPRRnh1DHCg8B738D+vdB5IAznbZw=";

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
