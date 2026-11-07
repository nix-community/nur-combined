{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-11-06";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "4a8c41c09934dec65da05c239839651b474c591f";
    hash = "sha256-5FZUwNhzXmYUhS5DglY2+IlxE0BTVEFyfFdC3rd0220=";
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
