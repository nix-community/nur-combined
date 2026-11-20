{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-11-19";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "6bca4c2c38a98a149d0d42db399718bda95689f9";
    hash = "sha256-0lMbxh57mq09rnFXImVlSPQJ6KaxC7+P80jX+znmMP8=";
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
