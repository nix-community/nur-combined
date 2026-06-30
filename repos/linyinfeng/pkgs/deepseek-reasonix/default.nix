{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "deepseek-reasonix";
  version = "1.14.0";
  src = fetchFromGitHub {
    owner = "esengine";
    repo = "DeepSeek-Reasonix";
    rev = "v${version}";
    sha256 = "sha256-cB77aNKFP+wRxjnzpN9d8/zedDuVB7r52EVUx0aaPYk=";
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
