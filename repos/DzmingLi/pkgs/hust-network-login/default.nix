{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hust-network-login";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "black-binary";
    repo = "hust-network-login";
    rev = "91a9e5a1bb6d7e2af02193d3a45e78aad5bd62d7";
    hash = "sha256-2T7OV5IQ5Cc6o0XF8ehAiWNBlcvdumyqGnE1bSR8TCw=";
  };

  cargoHash = "sha256-1K664YZyRGrOtpCQgDxFwMy3GRrVGnkQW5dF4syv2q4=";

  meta = with lib; {
    description = "为嵌入式设备设计的最小化华中科技大学校园网络认证工具";
    homepage = "https://github.com/black-binary/hust-network-login";
    license = licenses.mit;
    mainProgram = "hust-network-login";
  };
})
