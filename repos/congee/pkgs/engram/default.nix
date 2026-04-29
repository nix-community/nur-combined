{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "engram";
  version = "1.14.10";

  src = fetchFromGitHub {
    owner = "Gentleman-Programming";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-LVV7DqvltfGe6k0TqqeRKXPBIM5YP3Z8ayjdeRH61XQ=";
  };

  vendorHash = "sha256-O+pC4x4DKNUWr7Sx9iZOjK6a64wrQA4/lnjvkNLBX64=";

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
