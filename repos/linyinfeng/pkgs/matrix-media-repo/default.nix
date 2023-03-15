{ buildGo118Module, fetchFromGitHub, lib, nix-update-script, libde265 }:

buildGo118Module rec {
  pname = "matrix-media-repo";
  version = "1.2.13";
  src = fetchFromGitHub {
    owner = "turt2live";
    repo = "matrix-media-repo";
    rev = "v${version}";
    sha256 = "sha256-nBt2d5w4FrSnV5pTSphxbYXOiqMQzHuuYrTy2hG3cRw=";
  };

  vendorSha256 = "sha256-VtVovG9LjTnpLkQkeYzMDqqfAWX210uPda3I1TxFv68=";

  proxyVendor = true;

  preBuild = ''
    go run ./cmd/compile_assets
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/turt2live/matrix-media-repo/common/version.Version=${version}"
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "Matrix media repository with multi-domain in mind";
    homepage = "https://github.com/turt2live/matrix-media-repo";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
