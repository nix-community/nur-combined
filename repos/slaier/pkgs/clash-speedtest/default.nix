{ lib, buildGo118Module, sources, ... }:
let
  source = sources.clash-speedtest;
  module = "github.com/starudream/clash-speedtest";
in
buildGo118Module {
  inherit (source) pname version src;

  vendorSha256 = "sha256-93EV12MUG0OPSDCE/96+WrXLdB7IHpROEPSA147ijik=";

  ldflags = [
    "-s"
    "-w"
    "-X ${module}/config.VERSION=${source.version}"
    "-X ${module}/config.BIDTIME=20220619"
  ];
  tags = [
    "jsoniter"
    "viper_yaml3"
  ];

  doCheck = false;

  meta = with lib; {
    description = "clash proxy speedtest";
    homepage = "https://github.com/starudream/clash-speedtest";
    license = licenses.asl20;
  };
}

