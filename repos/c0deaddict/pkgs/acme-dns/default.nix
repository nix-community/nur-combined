{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  name = "acme-dns";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "joohoi";
    repo = "acme-dns";
    rev = "v${version}";
    hash = "sha256-tjVI+CaQTN1SB/RkTg0CJ1o9azb2ULwR1uKK5fJZ8fw=";
  };

  vendorHash = "sha256-n3icQQkdA0nCkvthsFsUTrYg0B3t8hROL4QXgBQRbSg=";

  meta = with lib; {
    homepage = "https://github.com/joohoi/acme-dns";
    description = "Limited DNS server with RESTful HTTP API to handle ACME DNS challenges easily and securely.";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
