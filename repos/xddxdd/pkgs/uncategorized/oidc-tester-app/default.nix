{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-10-20";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "56d5507f3d8609730603c058963b4da4db270e15";
    hash = "sha256-H2Gx1jKgU16LGCVnH4NgxDn+DguEanwFt8RYzWheu1c=";
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
