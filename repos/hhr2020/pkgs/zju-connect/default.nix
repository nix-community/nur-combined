{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "zju-connect";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "ZJU-Connect";
    rev = "v${version}";
    hash = "sha256-8QMdesmveXHmAKhuISmAE75La/KeybFqYSfAACfmIJE=";
  };

  vendorHash = "sha256-ANb3zcZCMqg6iO79q9CQEEN8DH0cwb7bAs3YmhfGTz8=";

  meta = {
    description = "ZJU RVPN 客户端的 Go 语言实现";
    homepage = "https://github.com/Mythologyli/ZJU-Connect";
    mainProgram = "zju-connect";
    license = lib.licenses.agpl3Only;
  };
}
