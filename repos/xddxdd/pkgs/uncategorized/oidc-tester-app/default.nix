{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-11-05";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "9381fb009b6002d6283263daf30f6d42e26f4c12";
    hash = "sha256-Ych0WHDNkpyOM1Q6L/x6ldt6VCSe2YsMPutDTKFZS80=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-YqwmYTkRb2NG+i4epl5QMSbgh63vY/91SBF43PWE4ME=";

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
