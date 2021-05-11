{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "terraform-ls";
  version = "0.16.2";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-5+h1fyTCp1jUZeKRCeDhfqAA11SMyR5nw2Y2x6JyIwY=";
  };

  vendorSha256 = "sha256-m5ddUwuTX0mSihkoGIMQKidptwUL8Bao5HgHJBWX0os=";

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
