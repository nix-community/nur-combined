{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-blame-someone-else";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "atlarator";
    repo = "git-blame-someone-else";
    rev = finalAttrs.version;
    sha256 = "sha256-xraG1dR5Q8oDlUXARgh0ql8eRwH4bJWblJFjH1wJcys=";
  };

  buildPhase = ''
    echo "no need to build"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 0755 git-blame-someone-else \
      $out/bin/git-blame-someone-else
    runHook postInstall
  '';

  meta = {
    description = "Blame someone else for your bad code";
    homepage = "https://github.com/jayphelps/git-blame-someone-else";
    license = lib.licenses.mit;
    mainProgram = "git-blame-someone-else";
  };
})
