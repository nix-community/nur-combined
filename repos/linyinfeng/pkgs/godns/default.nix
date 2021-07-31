{ sources, stdenv, lib, buildGoModule }:

buildGoModule rec {
  inherit (sources.godns) pname version src;

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
