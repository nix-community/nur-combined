{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:

buildGo126Module rec {
  pname = "gh-image";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "drogers0";
    repo = "gh-image";
    rev = "v${version}";
    hash = "sha256-5SeC6rer3pBMK7mnO+13JgGQLffqXCtNnP2n7KHCqz4=";
  };

  # go mod vendor matches every build tag, so it drags in the hbd-tagged
  # hackbrowserdata and chokes on an embedded .bin absent from its module zip.
  proxyVendor = true;
  vendorHash = "sha256-vqdkmjDLI+wpOOV3zK4pT+KG5zC/SKYmAdgs4GM1OKQ=";

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
