{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "geo";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "MetaCubeX";
    repo = "geo";
    rev = "v${version}";
    hash = "sha256-lwFBevf3iP90LgnfUqweCjPBJPr2vMFtRqQXXUC+cRA=";
  };

  vendorHash = "sha256-FXvuojlMZRzi8TIQ2aPiDH7F9c+2dpe4PYzYWljfUIc=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "An easy way to manage all your Geo resources. Available as both a CLI and a Go library";
    homepage = "https://github.com/MetaCubeX/geo";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "geo";
  };
}
