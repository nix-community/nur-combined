{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-11-20";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "b73d2f6011299be7eca727f477430146b4f664f9";
    hash = "sha256-YCjTbCWWIkToDPjW0Rikf5u+gH1RGWsDKv4IeTrCMOI=";
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
