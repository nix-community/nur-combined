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
    description = "自选优选 IP」测试 Cloudflare CDN 延迟和速度，获取最快 IP ！当然也支持其他 CDN / 网站 IP";
    homepage = "https://github.com/XIU2/CloudflareSpeedTest";
    license = licenses.gpl3Only;
    mainProgram = "CloudflareSpeedTest";
  };
}
