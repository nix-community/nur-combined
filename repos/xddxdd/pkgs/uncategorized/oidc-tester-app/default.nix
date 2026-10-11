{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-10-10";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "a15bb3ccaaba9094a0032a089341667a4d3e6f29";
    hash = "sha256-ulI3lVC5XcLdQe3wdV5VuBBehwHKP8mk+A0jHU8U+Es=";
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
