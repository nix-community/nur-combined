{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  wails,
}:

buildGoModule rec {
  pname = "reasonix";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "esengine";
    repo = "DeepSeek-Reasonix";
    rev = "v${version}";
    sha256 = "sha256-fRFqlXGAUcnB0zumwtr7NNzfHVdFu679n9J4ki7Yk3I=";
  };

  vendorHash = "sha256-ObDfNr9Olc6mFfIYx3yb4UxesZD+HXzN7mjxr/iT2p4=";

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
