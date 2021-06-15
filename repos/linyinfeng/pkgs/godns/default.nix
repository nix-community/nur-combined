{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "godns";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "TimothyYe";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0LFCUjzYqHiLQYiKdYJ8jCXiCDXdGCHk67wqsQhXlVM=";
  };

  vendorSha256 = "sha256-FZLDaMrPEyoTGFmGBlpqPWsMuobqwkBaot5qjcRJe9w=";

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
