{
  lib,
  stdenv,
  fetchFromGitHub,
  jq,
  nix-update-script,
  ...
}:

stdenv.mkDerivation {
  pname = "claude-code-setting-switcher";
  version = "0-unstable-2025-07-15";

  src = fetchFromGitHub {
    owner = "yoyooyooo";
    repo = "claude-code-config";
    rev = "449866d7daae8087abdfb8275eeb1367d8e35d72";
    hash = "sha256-mVs9IHXl7zYz77Jq3KjNV5/cR7yywiUvMWaORdjZiYI=";
  };

  propagatedBuildInputs = [ jq ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ccc $out/bin/ccsw
    chmod +x $out/bin/ccsw

    # Create symbolic link for compatibility
    ln -s ccsw $out/bin/ccc

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version=branch"
      ];
    };
  };

  meta = {
    description = "Claude Code configuration switcher - tool for managing different Claude API configurations";
    homepage = "https://github.com/yoyooyooo/claude-code-config";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ccsw";
  };
}
