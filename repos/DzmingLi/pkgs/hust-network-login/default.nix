{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hust-network-login";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "hust-network-login";
    rev = "547b77e504f251536ad61be84f2e39df22b8b4bf";
    hash = "sha256-k5bL9DxaOc5LmWomrkvQKZbQrZk40z/4J69TD5v53LE=";
  };

  cargoHash = "sha256-1K664YZyRGrOtpCQgDxFwMy3GRrVGnkQW5dF4syv2q4=";

  meta = with lib; {
    description = "为嵌入式设备设计的最小化华中科技大学校园网络认证工具";
    homepage = "https://github.com/DzmingLi/hust-network-login";
    license = licenses.mit;
    mainProgram = "hust-network-login";
  };
})
