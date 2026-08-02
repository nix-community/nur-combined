{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "deepseek-reasonix";
  version = "1.19.3";
  src = fetchFromGitHub {
    owner = "esengine";
    repo = "DeepSeek-Reasonix";
    rev = "v${version}";
    sha256 = "sha256-bBc8w+i27YWk19CyEy71nAnuEcCwi+zUmzQTiUIWDe4=";
  };

  vendorHash = "sha256-Byt7/DbSHZ+PJ8evWARRQHds/kyuydTyYH98pFwAxNY=";

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
