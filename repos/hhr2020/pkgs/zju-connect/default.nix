{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DMT2XpgIOEYDxQqKR8xA/E6NFNvMV8RQX3pYbth3/RA=";
  };

  vendorHash = "sha256-+yGwoEn0d40/QYpsFLhGzJJpki8KANvRAHjdd5KSWtw=";
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
