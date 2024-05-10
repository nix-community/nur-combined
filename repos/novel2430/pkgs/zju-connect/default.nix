{ lib
, fetchFromGitHub
, buildGoModule
}:

buildGoModule rec {

  pname = "zju-connect";
  version = "0.7.0";
  
  src = fetchFromGitHub ({
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-YM2sd8Tqm+PEg1kto34nJ3OmB5xcMs//3npYPUQXAkY=";
  });
  
  vendorHash = "sha256-f17lXPk5WrQRoIRC/LmVNaYvjvHowndiLTNQg6oFqdI=";

  meta = with lib; {
    description = "Zhejiang University RVPN Client in Go";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = with licenses; [ agpl3Only ];
    mainProgram = "zju-connect";
    platforms = platforms.all;
  };

}
