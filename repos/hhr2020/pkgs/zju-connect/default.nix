{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "zju-connect";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "ZJU-Connect";
    rev = "v${version}";
    hash = "sha256-r3kvjW5e66L5K6cHoC2OJWS1SRnKwk8W/YZOPgBr6cw=";
  };

  vendorHash = "sha256-npOYVm/d8Qpg+xrACK+ThMEniq40eKJfZtMAWrecBJk=";

  meta = {
    description = "ZJU RVPN 客户端的 Go 语言实现";
    homepage = "https://github.com/Mythologyli/ZJU-Connect";
    mainProgram = "zju-connect";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}
