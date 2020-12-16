{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tfk8s";
  version = "master";

  src = fetchFromGitHub {
    owner = "jrhouston";
    repo = "tfk8s";
    rev = "master";
    sha256 = "sha256-KIFyi//hMYrg36rv7u4t8fy8186OmpbltTwVPHM4tQ4=";
  };

  vendorSha256 = "sha256-syAu6AmVBq/5kG37bZysgCN11zjXieotB+bZpXt+2Qc=";
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://github.com/jrhouston/tfk8s";
    description =
      "A tool for converting Kubernetes YAML manifests to Terraform HCL";
    license = with licenses; [ mit ];
    platforms = platforms.unix;
  };
}
