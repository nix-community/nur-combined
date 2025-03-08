{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mouseless";
  version = "0.2.0";

  src = fetchFromGitHub {
    repo = pname;
    owner = "jbensmann";
    rev = "v${version}";
    hash = "sha256-iDSTV2ugvHoBuQWmMg2ILXP/Mlt7eq5B2dVaB0jwJOE=";
  };

  vendorHash = "sha256-2q7L9BVcAaT4h/vUcNjVc5nOAFnb4J3WabcEGxI+hsA=";

  ldFlags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Replacement for the physical mouse in Linux. Successor to xmouseless";
    homepage = "https://github.com/jbensmann/mouseless";
    changelog = "https://github.com/jbensmann/mouseless/releases/tag/${src.rev}";
    licenses = licenses.mit;
    mainProgram = "mouseless";
  };
}
