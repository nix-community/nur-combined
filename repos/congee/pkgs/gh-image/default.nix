{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gh-image";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "drogers0";
    repo = "gh-image";
    rev = "v${version}";
    hash = "sha256-UUImAoQoVcWN9uLRZA3Up0daQ4M9HEV5kDrBQU2F7NE=";
  };

  vendorHash = "sha256-QVr+MeqjnjzBrUjyMFOsTnONIJ2e1nFwr+szB8SaCuA=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/gh-image --help | grep -F "gh image extract-token"
    runHook postInstallCheck
  '';

  meta = {
    description = "GitHub CLI extension that uploads images to GitHub from the command line";
    homepage = "https://github.com/drogers0/gh-image";
    changelog = "https://github.com/drogers0/gh-image/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "gh-image";
  };
}
