{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "deepseek-reasonix";
  version = "1.14.1";
  src = fetchFromGitHub {
    owner = "esengine";
    repo = "DeepSeek-Reasonix";
    rev = "v${version}";
    sha256 = "sha256-KsV0TuOPp6QUQ3k0NRe9C2SbTI9nx65GjBU6i3DmKDY=";
  };

  vendorHash = "sha256-DHtdsmD3+iQzBSpgNHgX0tN+wRVINjlOq6yiIW75NQM=";

  subPackages = [
    "cmd/reasonix"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "DeepSeek-native AI coding agent for your terminal";
    homepage = "https://github.com/esengine/DeepSeek-Reasonix";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
