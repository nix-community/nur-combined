{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "1.0.0-beta.5";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wGAdoedIDp7shcU5JdbecgCG7Mf0gmXofRaQgkfynZc=";
  };

  vendorHash = "sha256-H+WtDkq8FckXuriEQNh1vhsGIkw1U7RlhQeAbO0jUXQ=";

  ldflags = [ "-s" ];

  meta = {
    description = "ZJU RVPN 客户端的 Go 语言实现";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "zju-connect";
  };
})
