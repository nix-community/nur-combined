{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  name = "acme-dns";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "joohoi";
    repo = "acme-dns";
    rev = "v${version}";
    sha256 = "sha256-qQwvhouqzkChWeu65epgoeMNqZyAD18T+xqEMgdMbhA=";
  };

  vendorSha256 = "sha256-q/P+cH2OihvPxPj2XWeLsTBHzQQABp0zjnof+Ys/qKo=";
  modSha256 = vendorSha256;

  meta = with lib; {
    homepage = "https://github.com/joohoi/acme-dns";
    description = "Limited DNS server with RESTful HTTP API to handle ACME DNS challenges easily and securely.";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
