{ sources, lib, buildGoModule }:

buildGoModule rec {
  inherit (sources.godns) pname version src;
  # TODO auto update vendor hash
  vendorSha256 = "sha256-FZLDaMrPEyoTGFmGBlpqPWsMuobqwkBaot5qjcRJe9w=";

  doCheck = false;

  ldflags = [ "-s" "-w" "-X main.Version=${version}" ];

  meta = with lib; {
    description = "A dynamic DNS client tool supports AliDNS, Cloudflare, Google Domains, DNSPod, HE.net & DuckDNS & DreamHost, etc, written in Go";
    homepage = "https://github.com/TimothyYe/godns";
    license = licenses.asl20;
  };
}
