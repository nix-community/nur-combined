{ buildGoModule
, lib
, sources
, ...
} @ args:

buildGoModule rec {
  inherit (sources.cloudpan189-go) pname version src;
  vendorSha256 = "sha256-2zqCpOvrXCv7/oeR6bCLt1esdlMFQ33gD8Y36CghXYo=";
  doCheck = false;

  meta = with lib; {
    description = "天翼云盘命令行客户端(CLI)，基于GO语言实现";
    homepage = "https://github.com/tickstep/cloudpan189-go";
    license = licenses.asl20;
  };
}
