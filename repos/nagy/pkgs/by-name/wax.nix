{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "wax";
  version = "unstable-2022-10-01";

  src = fetchFromGitHub {
    owner = "LingDong-";
    repo = "wax";
    rev = "be0380a5317aa663eb8f188ec464ae2fdbcdf2f3";
    hash = "sha256-kSirGKz+Pn6pMrLx2N3pXQwNJv1bgkSP6G7lBP+gQn4=";
  };

  makeFlags = [ "c" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin/ waxc

    runHook postInstall
  '';

  meta = with lib; {
    description = "A tiny programming language that transpiles to C, C++, Java, TypeScript, Python, C#, Swift, Lua and WebAssembly";
    homepage = "https://github.com/LingDong-/wax";
    license = licenses.mit;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "waxc";
  };
}
