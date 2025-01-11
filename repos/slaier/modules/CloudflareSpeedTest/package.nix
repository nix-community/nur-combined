{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "CloudflareSpeedTest";
  version = "2.2.5";

  src = fetchFromGitHub {
    owner = "XIU2";
    repo = "CloudflareSpeedTest";
    rev = "v${version}";
    hash = "sha256-j95THaMm4nOoKiz+Qq2CHZofHmuU+h1s5IHCwwDiIc0=";
  };

  vendorHash = "sha256-CHhXprObZvVU2XY2Ja9JFvFCY2YoxMyaGsd3/IpVI2c=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "自选优选 IP」测试 Cloudflare CDN 延迟和速度，获取最快 IP ！当然也支持其他 CDN / 网站 IP";
    homepage = "https://github.com/XIU2/CloudflareSpeedTest";
    license = licenses.gpl3Only;
    mainProgram = "CloudflareSpeedTest";
  };
}
