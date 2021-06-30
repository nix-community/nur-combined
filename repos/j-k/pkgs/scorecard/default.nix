{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "scorecard";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ossf";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-rL+0YJjzVMxAYwXQOjXd6Zp1S/0ZMzw+A/ceZk3O/W8=";
  };

  vendorSha256 = "sha256-BVs0J71k8Xqgq/cl4yAWBVOyVQuKeVNXBBuFGKljypM=";

  excludedPackages="\\(gitcache\\|e2e\\)";

  ldflags = [ "-s" "-w" ];

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
