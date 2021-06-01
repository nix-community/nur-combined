{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-staticmaps";
  version = "2021-04-25";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = pname;
    rev = "2e6e19a99c28a6e68b24e2f2fbcc084da8aee8ac";
    hash = "sha256-yTnlX55+B4Qh+Zcq7PdAK3nIB36iHvZOo+l4z/ECO6Y=";
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
