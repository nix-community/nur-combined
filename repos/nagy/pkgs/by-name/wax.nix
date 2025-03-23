{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "wax";
  version = "0.0.1-unstable-2025-03-03";

  src = fetchFromGitHub {
    owner = "LingDong-";
    repo = "wax";
    rev = "901d17c4b3e86d03616295f81353b7aa6ee28841";
    hash = "sha256-w86rAiLQ04YYbk7kuW6KJ0NpHGf1eKzDv8BYzO/pHR4=";
  };

  makeFlags = [ "c" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin/ waxc

    runHook postInstall
  '';

  meta = {
    description = "Tiny programming language that transpiles to C, C++, Java, TypeScript, Python, C#, Swift, Lua and WebAssembly";
    homepage = "https://github.com/LingDong-/wax";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "waxc";
  };
}
