{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  bashNonInteractive,
  coreutils,
  git,
  gnused,
  nodejs,
}:

buildNpmPackage {
  pname = "calldiff";
  version = "0.6.0-unstable-2026-08-13";

  src = fetchFromGitHub {
    owner = "tanishqkancharla";
    repo = "calldiff";
    rev = "d58c48b33327c1c833b88df521f6838e9a5cc8c5";
    hash = "sha256-6Lefc0rq4bFyptycBK2Uz8bZR648ca5hymWMvgsJVC4=";
  };

  npmDepsHash = "sha256-hEhU73MH5ueh3RRYCaTfAI23diwWViThvEw7ip2O9j8=";

  nativeBuildInputs = [ makeWrapper ];

  # calldiff shells out to git, and to npm to install every tree-sitter grammar
  # but the bundled typescript one; npm's install scripts need sh, sed and uname
  postInstall = ''
    wrapProgram $out/bin/calldiff \
      --prefix PATH : ${
        lib.makeBinPath [
          bashNonInteractive
          coreutils
          git
          gnused
          nodejs
        ]
      }
  '';

  meta = {
    description = "Diffs of function call stacks across git commits, built on Tree-sitter";
    homepage = "https://github.com/tanishqkancharla/calldiff";
    license = lib.licenses.mit;
    mainProgram = "calldiff";
  };
}
