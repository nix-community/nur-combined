{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "engram";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "Gentleman-Programming";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-nF64HUlc2wnZFYlI8QVPB77IqA6SHY09W6kQH1CdR7E=";
  };

  vendorHash = "sha256-M6+OxF+qigWmjMCEeQn2nvpZqDxh9D4bXewGGUW6QEQ=";

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
