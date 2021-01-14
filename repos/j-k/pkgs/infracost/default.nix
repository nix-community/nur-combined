{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "infracost";
  version = "0.7.13";

  src = fetchFromGitHub {
    owner = "infracost";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-qxu3mbaqKuLOVPvsDKooX6tgFIvulqAssioUGcyGMAE=";
  };

  vendorSha256 = "sha256-aKXoukv/q6VLI7JLbX4lN+ObDJwVnxZTKUPtp0sGWoQ=";

  subPackages = [ "cmd/infracost" ];

  buildFlagsArray = [
    "-ldflags="
    "-s"
    "-w"
    "-X github.com/infracost/${pname}/internal/version.Version=v${version}"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Cloud cost estimates for Terraform in your CLI and pull requests";
    longDescription = ''
      Infracost shows hourly and monthly cost estimates for a Terraform project.
      This helps developers, DevOps et al. quickly see the cost breakdown and compare different deployment options upfront.
    '';
    homepage = "https://infracost.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
    platforms = platforms.all;
  };
}
