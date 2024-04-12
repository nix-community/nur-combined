{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mouseless";
  version = "0.1.5";

  src = fetchFromGitHub {
    repo = pname;
    owner = "jbensmann";
    rev = "v${version}";
    hash = "sha256-P6GTwnutJMyrLjggCccyyDFoaW5Pt/EfT0WHm2cLsuA=";
  };

  vendorHash = "sha256-5/sfhfLAVjSuzaBSmx2YmpS/c43LAV73ofHRx1UWc3o=";

  ldFlags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Replacement for the physical mouse in Linux. Successor to xmouseless";
    homepage = "https://github.com/jbensmann/mouseless";
    changelog = "https://github.com/jbensmann/mouseless/releases/tag/${src.rev}";
    licenses = licenses.mit;
    mainProgram = "mouseless";
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
