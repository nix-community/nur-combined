{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-staticmaps";
  version = "2021-04-12";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = pname;
    rev = "9eef5d84e2f2fd705ebb1cd0c0601cf2301ad9ca";
    hash = "sha256-HH7HjVdv9yTpE7on6PDXqiUSGQzSqyh5/+psFm53+WQ=";
  };

  patches = [ ./extra-tileproviders.patch ];

  vendorSha256 = "sha256-HHeMGRMaG6llmhTWrSOlYVBB4LiS2FeMxagKvkfRaXc=";

  meta = with lib; {
    description = "A go (golang) library and command line tool to render static map images using OpenStreetMap tiles";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
