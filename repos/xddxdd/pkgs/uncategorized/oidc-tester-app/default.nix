{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-10-28";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "146cfd9429b6ee9623e556a45ecaec00c629492f";
    hash = "sha256-IWPIOHKTKMYhnWCBanSkqqmD35uMU6tAg5ropvS2rIc=";
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
