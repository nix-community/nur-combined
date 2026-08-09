{
  emacsPackages,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  ...
}:
# emacs-mcp-server (MCP server exposing Emacs to LLM agents) is not on MELPA.
# The tool definitions live in tools/, which trivialBuild ignores, so flatten
# them into the root first; keep the stdio wrapper scripts alongside the elisp
# for `claude mcp add emacs .../mcp-wrapper.sh <sock>`.
emacsPackages.trivialBuild {
  pname = "mcp-server";
  version = "0.7.0-unstable-2026-05-04";

  src = fetchFromGitHub {
    owner = "rhblind";
    repo = "emacs-mcp-server";
    rev = "a5d749cf9880598f66308545985526fd4460627f";
    hash = "sha256-ugaOqSnphgUKVm0+sem6oNthOFHIB5uIpksyTuGSsxE=";
  };

  preBuild = ''
    cp tools/*.el .
  '';

  postInstall = ''
    install -m755 mcp-wrapper.py mcp-wrapper.sh $out/share/emacs/site-lisp/
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-mcp-server --version=branch";

  meta = {
    description = "Pure Elisp MCP server exposing Emacs to LLM agents";
    homepage = "https://github.com/rhblind/emacs-mcp-server";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
