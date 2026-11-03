{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "engram";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "Gentleman-Programming";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-lVLGjn/eYUNy5S/Ct9lTWGiFso40EKrlIDmD+aUaDgg=";
  };

  vendorHash = "sha256-hkwwuqar4ngDUWM2XctkiVm8TpfQWnUws/sDxDyvQxU=";

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
