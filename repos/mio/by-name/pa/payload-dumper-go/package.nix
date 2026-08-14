{
  lib,
  buildGoModule,
  fetchFromGitHub,
  xz,
}:

buildGoModule rec {
  pname = "payload-dumper-go";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ssut";
    repo = "payload-dumper-go";
    rev = "2.0.0";
    hash = "sha256-A9WVPn/MeLTt1ySmN8Xge/Ye8BDhtETJstxB6mI5FFU=";
  };

  vendorHash = "sha256-hjVgIVOwci1IXaV+0AHgB36pMSgQsYi3A+9NIMsSz54=";

  buildInputs = [
    xz
  ];

  meta = with lib; {
    description = "An Android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "payload-dumper-go";
  };
}
