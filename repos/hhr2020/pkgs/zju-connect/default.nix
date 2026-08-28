{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BPBdydGiKRmVwRY4Fn41uCU0R06qyN/FLw5C97Sdltw=";
  };

  vendorHash = "sha256-6z7B8RC7hhZOGv+i5u/zap2qivoxRW6wHY4bCU4mLOI=";
  proxyVendor = true;

  ldflags = [ "-s" ];

  meta = {
    description = "ZJU RVPN 客户端的 Go 语言实现";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "zju-connect";
  };
})
