{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-10-22";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "019a0e9064569ab7d63151e20bb2f912a1e2acd3";
    hash = "sha256-VIOlrNjS175230mz3dWh/Y4TqZoxZkHy/t4fM3qgOtc=";
  };
  __structuredAttrs = true;
  strictDeps = true;
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
