{ lib
, fetchFromGitHub
, buildGoModule
}:

buildGoModule rec {

  pname = "zju-connect";
  version = "1.2.1";
  
  src = fetchFromGitHub ({
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-TdXO/dK41zTR00BCOB3TcMTiip2XBSjNx024WpiIT0Q=";
  });
  
  vendorHash = "sha256-lDxroSrPwwYF2w7qXR+PQYkre8E+nOwPzDiMoeScjO0=";

  meta = with lib; {
    description = "Zhejiang University RVPN Client in Go";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = with licenses; [ agpl3Only ];
    mainProgram = "zju-connect";
    platforms = platforms.all;
  };

}
