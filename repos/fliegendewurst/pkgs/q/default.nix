{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "q";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "natesales";
    repo = "q";
    rev = "v${version}";
    sha256 = "1qvpw21b7w3awa37vy14xvw4ai3nwrq0qd7gnpl4vx4nd9m5f970";
  };

  vendorSha256 = "1mv533hbs6bgfzrgnpbp3b1rijc7xdn93jnr8lksh8z7ddkw44wc";

  ldflags = [
    "-X main.version=${version}"
  ];

  doCheck = false; # requires network access

  meta = with lib; {
    description = "Tiny command line DNS client with support for UDP, TCP, DoT, DoH, DoQ and ODoH";
    homepage = "https://github.com/natesales/q";
    license = licenses.gpl3;
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
