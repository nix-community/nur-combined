{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## stevemolitor/monet: claude-code.el 的 MCP/IDE 配套——websocket server，让
## Claude 看到选区/诊断、在 Emacs 里开 diff。接法（见 side-panels.el）：
##   (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
##   (monet-mode 1)
emacsPackages.trivialBuild {
  pname = "monet";
  version = "0-unstable-2026-04-18";

  src = fetchFromGitHub {
    owner = "stevemolitor";
    repo = "monet";
    rev = "ee2e35557e8ae07de842c435486f7c152f3750e0";
    hash = "sha256-C5t7pKcp8lqZUPiWAcrx2H7Gba2NSpojUPxG5AnrMJg=";
  };

  ## 顶层 test-diff-visibility.el 是测试文件，别打进包/编译。
  postPatch = "rm -f test-diff-visibility.el";

  packageRequires = with emacsPackages; [ websocket ];

  meta = with lib; {
    description = "MCP/IDE server (websocket) for Claude Code in Emacs";
    homepage = "https://github.com/stevemolitor/monet";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
