{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## benthamite/codex: OpenAI Codex CLI 集成（在 Emacs 里跑 Codex，
## 发送命令/选区/文件、transient 菜单）。后端默认 eat。
##
## Consumer:
##   emacsWithPackages (epkgs: [ ... epkgs.codex ... ])
emacsPackages.trivialBuild {
  pname = "codex";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "benthamite";
    repo = "codex";
    rev = "53c6e3fe21c1ff724b5807c6f225506ca71afff6";
    sha256 = "0sf7w08k1472hngzrz88dg8a15h8pj9bs7mdc0164iqc9yd1cqvg";
  };

  packageRequires = with emacsPackages; [ transient inheritenv eat ];

  meta = with lib; {
    description = "OpenAI Codex CLI integration for Emacs";
    homepage = "https://github.com/benthamite/codex";
    platforms = platforms.unix;
  };
}
