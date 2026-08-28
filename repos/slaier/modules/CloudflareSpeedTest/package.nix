{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "CloudflareSpeedTest";
  version = "2.3.5";

  src = fetchFromGitHub {
    owner = "XIU2";
    repo = "CloudflareSpeedTest";
    rev = "v${version}";
    hash = "sha256-C/LvXIC2ng5FtEDMhoxilTayKVplJfzD27QLT7pbSVY=";
  };

  vendorHash = "sha256-4h3Jf3K6uEm79KAy46v69wby01zf2tfdZxGeTyUXvdk=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Test Cloudflare CDN latency and speed to find the fastest IP! It also supports IPs for other CDNs and websites.";
    homepage = "https://github.com/XIU2/CloudflareSpeedTest";
    license = licenses.gpl3Only;
    mainProgram = "CloudflareSpeedTest";
  };
}
