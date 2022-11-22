{ buildGoModule
, lib
, sources
, ...
} @ args:

buildGoModule rec {
  inherit (sources.baidupcs-go) pname version src;
  vendorSha256 = "sha256-t7HIncTsq6/kT4QJUA14Yik1Co+GqxkEBzdKL9q/KcM=";
  doCheck = false;

  meta = with lib; {
    description = "iikira/BaiduPCS-Go 原版基础上集成了分享链接/秒传链接转存功能";
    homepage = "https://github.com/qjfoidnh/BaiduPCS-Go";
    license = licenses.asl20;
  };
}
