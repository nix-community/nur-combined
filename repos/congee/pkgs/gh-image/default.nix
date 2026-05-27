{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:

buildGo126Module rec {
  pname = "gh-image";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "drogers0";
    repo = "gh-image";
    rev = "v${version}";
    hash = "sha256-lH73UueHmEvuD0nkTobmq+EMqCy9rMeIMvLL8/jYE3U=";
  };

  vendorHash = "sha256-YD0owtlnJyeytr8TTWcLNAEgXH5Nmd/9IJrg6TM9A3U=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
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
    changelog = "https://github.com/drogers0/gh-image/commits/master";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "gh-image";
  };
}
