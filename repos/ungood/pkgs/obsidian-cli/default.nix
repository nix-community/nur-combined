{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "obsidian-cli";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "Yakitrak";
    repo = "obsidian-cli";
    rev = "v${version}";
    hash = "sha256-oIEiIzdbtwCeuBTii+BdvTmfi3YuMSSngXMDFuelJVc=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Interact with Obsidian in the terminal.";
    homepage = "https://github.com/Yakitrak/obsidian-cli";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "obsidian-cli";
  };

  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
}
