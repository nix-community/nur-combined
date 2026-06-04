{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  wails,
}:

buildGoModule rec {
  pname = "reasonix";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "esengine";
    repo = "DeepSeek-Reasonix";
    rev = "v${version}";
    sha256 = "sha256-67n4DRCOW6QMbNIvGmiRlb0DvBkmD0LricPFVwa6rag=";
  };

  vendorHash = "sha256-JguEYEkC+UfC4SQdZ9czCjUaoi9qyUktQ65Di8emZ4A=";

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
