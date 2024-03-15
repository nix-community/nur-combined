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
  version = "1.3.4";
  src = fetchFromGitHub {
    owner = "turt2live";
    repo = "matrix-media-repo";
    rev = "v${version}";
    sha256 = "sha256-wC69OiB3HjRs/i46+E1YS+M4zKmvH5vENHyfgU7nt1I=";
  };

  vendorHash = "sha256-tt9TybU7oBM2qpJz9XpjrqBiCgoAxkxUOztu3eT6zPY=";

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
