{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "aws-s3-reverse-proxy";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "Kriechi";
    repo = "aws-s3-reverse-proxy";
    rev = "v${version}";
    sha256 = "sha256-mCnuR2fbtWx0j6bz48gZArOA9KOZnD3pOr079z9wStY=";
  };

  vendorSha256 = "sha256-y17kEOpaqmfNvUgvMMQ2pqGpvm43IHW8YpA4Axlyshg=";

  meta = with lib; {
    description = "Reverse-proxy all incoming S3 API calls to the public AWS S3 backend";
    homepage = "https://github.com/Kriechi/aws-s3-reverse-proxy";
    license = licenses.mit;
  };
}

