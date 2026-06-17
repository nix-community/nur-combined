{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "deepseek-reasonix";
  version = "1.9.0";
  src = fetchFromGitHub {
    owner = "esengine";
    repo = "DeepSeek-Reasonix";
    rev = "v${version}";
    sha256 = "sha256-Pm8yY6eqADGDii3b7DLYQ7jjuIJedprxbMEIkJv7hZY=";
  };

  vendorHash = "sha256-mbHQDoSEj+56kqrPrinuQY3XEw4oBHoOrSO6iW62R7g=";

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
