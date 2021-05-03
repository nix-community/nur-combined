{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "godns";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "TimothyYe";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-nPJ3E0YJa5i3zT3UYb6tO71uYVr68xtenS9ByDXBQcA=";
  };

  vendorSha256 = "sha256-8WAfBOyMe45NOXa7Dot0WQWoaSzYG6Jx1zQqY5rTz5o=";

  doCheck = false;

  buildFlagsArray = [
    "-ldflags="
    "-X main.Version=${version}"
  ];

  meta = with lib; {
    description = "A dynamic DNS client tool supports AliDNS, Cloudflare, Google Domains, DNSPod, HE.net & DuckDNS & DreamHost, etc, written in Go.";
    homepage = "https://github.com/TimothyYe/godns";
    license = licenses.asl20;
  };
}
