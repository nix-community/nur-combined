{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "engram";
  version = "3.5.4";

  src = fetchFromGitHub {
    owner = "Gentleman-Programming";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-gFotVxsQXqgE5jfk17X/yP/kNvwNPcPWi+OWu2H19Bg=";
  };

  vendorHash = "sha256-LH8sSmer918+KL5hnOju7b5NsZo+W9sd3HhkQgjS2Ho=";

  subPackages = [ "cmd/engram" ];
  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";
  versionCheckKeepEnvironment = "HOME";
  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    runHook preInstallCheck
    runHook postInstallCheck
  '';

  meta = {
    description = "Persistent memory system for AI coding agents";
    homepage = "https://github.com/Gentleman-Programming/engram";
    changelog = "https://github.com/Gentleman-Programming/engram/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "engram";
  };
}
