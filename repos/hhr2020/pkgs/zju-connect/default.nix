{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "zju-connect";
  version = "1.0.0-beta.4";

  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "ZJU-Connect";
    rev = "v${version}";
    hash = "sha256-tc5R/mhA/AyMNBRlzp1g+zJMTi+iu0H9KpD4CnVoD0U=";
  };

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.25.6" "go 1.25.5"
  '';

  vendorHash = "sha256-H+WtDkq8FckXuriEQNh1vhsGIkw1U7RlhQeAbO0jUXQ=";

  meta = {
    description = "ZJU RVPN 客户端的 Go 语言实现";
    homepage = "https://github.com/Mythologyli/ZJU-Connect";
    mainProgram = "zju-connect";
    license = lib.licenses.agpl3Only;
  };
}
