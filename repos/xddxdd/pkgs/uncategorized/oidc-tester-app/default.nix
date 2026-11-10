{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-11-10";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "0a97ece8fb0a6dd8f1b40a0f9d95fd44a85cba36";
    hash = "sha256-DfZxUAld1kf2QiUfnP/CwInEoSixM+J2+R+pCcLcoGw=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-r5Ih7IjaSBaGMhFT6mEoXoe+mqWS7QH7HFCGLTAXLbo=";

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
