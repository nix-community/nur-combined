{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "pruner";
  version = "1.0.0-alpha.9";

  src = fetchFromGitHub {
    owner = "pruner-formatter";
    repo = "pruner";
    rev = "v${version}";
    hash = "sha256-1vicEI84f7wGU0/0tEDN6EImkjVX0/SJIMASzrvZEPk=";
  };

  cargoHash = "sha256-8T4v3QZk1PNFCvgAa6q+fXCXuasPE8miGuM84MftbGU=";

  doCheck = false; # missing treesitter files

  meta = {
    description = "A TreeSitter-powered formatter orchestrator";
    longDescription = ''
      Pruner is a language-agnostic, TreeSitter-powered formatter that allows
      encapsulating all the formatting rules of your project behind a shared,
      re-usable piece of config. It uses Tree-Sitter to parse and understand
      source code files containing embedded languages, and can format those
      embedded regions using their native formatting toolchain.
    '';
    homepage = "https://pruner-formatter.github.io";
    changelog = "https://github.com/pruner-formatter/pruner/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "pruner";
  };
}
