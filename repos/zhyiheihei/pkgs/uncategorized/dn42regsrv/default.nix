# dn42regsrv：dn42 registry 的 HTTP API 服务（burble 的 canonical ROA 生成器），
# 社区公开 ROA 数据（dn42.burble.com/roa/...）即由本工具产出。GoRTR JSON、
# bird1/bird2、OpenBGPd 格式齐备。ml-laptop 用它对着本地 dn42 registry 克隆
# 本地生成 ROA，替代对社区聚合 JSON 的外部抓取（复刻作者私有管线）。
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "dn42regsrv";
  version = "unstable-2025-04-20";

  src = fetchFromGitHub {
    owner = "elburb";
    repo = "dn42regsrv";
    rev = "261a18c4517056925a16cd8302447b53cb3f8f1e";
    hash = "sha256-CTOprETBe1oHI5gSVFqjhSNas/NNeOcr8hQPqbYHSig=";
  };

  vendorHash = "sha256-J48SavDbdyyQmQq8M7tPL1+XprHM1FMSPjpbExRBDV0=";

  # 上游 go.sum 是 Go 1.14 时代的残缺版（缺 logrus 传递依赖），本地 go mod tidy
  # 补全后随包携带
  postPatch = ''
    cp ${./go.mod} go.mod
    cp ${./go.sum} go.sum
  '';

  # Web UI 静态页随二进制走，运行时 -s 指向
  postInstall = ''
    mkdir -p $out/share/dn42regsrv
    cp -r ${src}/StaticRoot $out/share/dn42regsrv/StaticRoot
  '';

  meta = {
    description = "dn42 registry HTTP API server and ROA generator";
    homepage = "https://git.burble.com/burble.dn42/dn42regsrv";
    license = lib.licenses.gpl2;
  };
}