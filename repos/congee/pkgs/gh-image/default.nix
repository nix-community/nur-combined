{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:

buildGo126Module rec {
  pname = "gh-image";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "drogers0";
    repo = "gh-image";
    rev = "v${version}";
    hash = "sha256-3hy3YJ4ISlXCNaXC9+IgsIHE5gbZTo3HMXSyC/994jU=";
  };

  # go mod vendor matches every build tag, so it drags in the hbd-tagged
  # hackbrowserdata and chokes on an embedded .bin absent from its module zip.
  proxyVendor = true;
  vendorHash = "sha256-YqJmar98oy6Q9mzkBag2h/Hf8in0Wdwf3jM+EPHAVho=";

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
