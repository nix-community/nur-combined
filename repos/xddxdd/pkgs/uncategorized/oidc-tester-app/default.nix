{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-11-07";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "028aadd487f852a0159cc3ce1d4b3c83fbbe94a6";
    hash = "sha256-u+flUaUrd9gT02gLFSK0sitvv2O7Xr8qFo9/zDR98/w=";
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
