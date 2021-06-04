{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "terraform-ls";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-DQER00n6nbyPo/Q+Nbj/w94CHNgiGJor8kbl3RFVEkY=";
  };

  vendorSha256 = "sha256-hZqU7vnRh2fibpIGhPyOn5LfCdjZh82XpvfwhwnCrrs=";

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-s -w -X main.version=v${version} -X main.prerelease=")
  '';

  preCheck = ''
    # Remove test that requires networking
    rm internal/terraform/exec/exec_test.go
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/terraform-ls --help
    $out/bin/terraform-ls version | grep "v${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/hashicorp/terraform-ls";
    changelog = "https://github.com/hashicorp/terraform-ls/blob/v${version}/CHANGELOG.md";
    description = "Terraform Language Server";
    license = licenses.mpl20;
    maintainers = with maintainers; [ jk ];
  };
}
