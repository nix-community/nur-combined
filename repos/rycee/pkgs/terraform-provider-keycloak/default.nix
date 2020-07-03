{ buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "terraform-provider-keycloak";
  version = "1.19.0";
  goPackagePath = "github.com/mrparkers/terraform-provider-keycloak";
  subPackages = [ "." ];
  src = fetchFromGitHub {
    owner = "mrparkers";
    repo = pname;
    rev = version;
    sha256 = "0z60n77q2gxli25allf86vcjl9vc9xy5ybjj2k6sz776kykz40nm";
  };
  goDeps = ./deps.nix;
  # Terraform allow checking the provider versions, but this breaks if
  # the versions are not provided via file paths.
  postBuild = "mv go/bin/${pname}{,_v${version}}";
}
