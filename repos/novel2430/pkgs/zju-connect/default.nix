{ lib
, fetchFromGitHub
, buildGoModule
}:

buildGoModule rec {

  pname = "zju-connect";
  version = "0.7.1";
  
  src = fetchFromGitHub ({
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-r3kvjW5e66L5K6cHoC2OJWS1SRnKwk8W/YZOPgBr6cw=";
  });
  
  vendorHash = "sha256-npOYVm/d8Qpg+xrACK+ThMEniq40eKJfZtMAWrecBJk=";

  meta = with lib; {
    description = "Zhejiang University RVPN Client in Go";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = with licenses; [ agpl3Only ];
    mainProgram = "zju-connect";
    platforms = platforms.all;
  };

}
