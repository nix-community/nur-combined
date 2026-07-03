{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## stevemolitor/claude-code.el: Claude Code CLI 集成（在 Emacs 里跑 Claude，
## 发送选区/文件、transient 菜单）。配套 monet 做 MCP/IDE 集成。后端默认 eat。
##
## 不进 nixpkgs 的原因：nixpkgs 的 emacsPackages.claude-code 是 yuya373 的另一套
## 实现，配不了 stevemolitor 的 monet。
##
## Consumer:
##   emacsWithPackages (epkgs: [ ... epkgs.claude-code epkgs.monet ... ])
emacsPackages.trivialBuild {
  pname = "claude-code";
  version = "0-unstable-2026-04-30";

  src = fetchFromGitHub {
    owner = "stevemolitor";
    repo = "claude-code.el";
    rev = "03199df8b3a1e9cd4857f0851f7a912ba524aff3";
    hash = "sha256-5QJrWIu4EgnHcOqMwlrs2JBBx7aI9OaSJswesr6Apfk=";
  };

  ## Package-Requires: transient + inheritenv；vterm 是软 require(nil t) 不必带；
  ## eat 是默认终端后端（运行时）。
  packageRequires = with emacsPackages; [ transient inheritenv eat ];

  meta = with lib; {
    description = "Claude Code CLI integration for Emacs (stevemolitor)";
    homepage = "https://github.com/stevemolitor/claude-code.el";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
