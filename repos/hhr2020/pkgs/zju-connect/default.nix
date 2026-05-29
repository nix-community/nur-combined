{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-luB1Zv5lzkyAt7BAH3jtXEnwXsUbodT/uqkaD8rbmCI=";
  };

  vendorHash = "sha256-lDxroSrPwwYF2w7qXR+PQYkre8E+nOwPzDiMoeScjO0=";

  ldflags = [ "-s" ];

  meta = {
    description = "ZJU RVPN 客户端的 Go 语言实现";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "zju-connect";
  };
})
