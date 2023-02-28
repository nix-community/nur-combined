{ buildGoModule, lib, fetchFromGitHub }:

buildGoModule rec {
  pname = "deck";
  version = "1.19.0";
  sha = "31c4856";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = pname ;
    rev = "v${version}";
    sha256 = "sha256-KO4QROAq6QvHy/dz4vVDloU3KnWiekOvvPat+Fz++RE=";
  };

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${version}"
    "-X github.com/kong/deck/cmd.COMMIT=${sha}"
  ];
  vendorSha256 = "sha256-7bPduax9CukRRNlECKJ0XRQBfxhuxNm/MJeM7A4En30=";

  meta = with lib; {
    description = "decK provides declarative configuration and drift detection for Kong.";
    homepage    = "https://github.com/Kong/deck";
    license     = licenses.asl20;
  };
}
