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
  version = "1.3.7";
  src = fetchFromGitHub {
    owner = "turt2live";
    repo = "matrix-media-repo";
    rev = "v${version}";
    sha256 = "sha256-trVn+Mn98aJLQCpQX1+qps/uuA5+8zeDoM94eauxHO8=";
  };

  vendorHash = "sha256-lESa81bcpPCUGi7IDk7yEnyHFtWvBd9J7VHmB5EF9tg=";

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
