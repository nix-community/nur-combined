{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "aws-s3-reverse-proxy";
  version = "1.1.1";
  src = fetchFromGitHub {
    owner = "linyinfeng";
    repo = "aws-s3-reverse-proxy";
    rev = "v${version}";
    sha256 = "sha256-7wAjisl/KqZwtMWvnFYjFDAXKiH+yagqYX00p3nIg9g=";
  };

  vendorSha256 = "sha256-UXlDbhG2EXFgk0fGFrxdDHopiuFJtY/YH1BF4/tVrCU=";

  meta = with lib; {
    description = "Reverse-proxy all incoming S3 API calls to the public AWS S3 backend";
    homepage = "https://github.com/Kriechi/aws-s3-reverse-proxy";
    license = licenses.mit;
  };
}

