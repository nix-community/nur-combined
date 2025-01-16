{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  libde265,
  pkg-config,
  libheif,
}:

buildGoModule rec {
  pname = "matrix-media-repo";
  version = "1.3.8";
  src = fetchFromGitHub {
    owner = "turt2live";
    repo = "matrix-media-repo";
    rev = "v${version}";
    sha256 = "sha256-KP1ZyHqeATxk1PCLuM6lPk+GB4Rd0f7ppKVETIURx28=";
  };

  vendorHash = "sha256-TWebQEdMhyDkWO5HsgnebpDNu/hl6+dwd7eUpAOPGSE=";

  proxyVendor = true;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libheif ];

  preBuild = ''
    go run ./cmd/utilities/compile_assets
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
    # TODO broken
    # due to outdated libheif version in nixpkgs
    # matrix-media-repo requires libheif 1.16.2
    broken = true;
  };
}
