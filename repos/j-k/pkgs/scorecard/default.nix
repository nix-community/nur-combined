{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "scorecard";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ossf";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-y/hqfk1fDnp7Nrf3NwHQRQwlSiCXt4Xm15qoTIFlCKk=";
  };

  vendorSha256 = "sha256-Hs1W1A6M1Qq3HUd+2BamXEmaCS2d/s5a7po9iFo9TtA=";

  excludedPackages="\\(gitcache\\|e2e\\)";

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-s -w")
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/scorecard --help
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/ossf/scorecard";
    changelog = "https://github.com/ossf/scorecard/releases/tag/v${version}";
    description = "A program that shows security scorecard for an open source software";
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
