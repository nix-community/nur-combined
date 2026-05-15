{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "inc-rename-nvim";
  version = "0074b55";

  src = fetchFromGitHub {
    owner = "smjonas";
    repo = "inc-rename.nvim";
    rev = "0074b551a17338ccdcd299bd86687cc651bcb33d";
    hash = "sha256-WDvzCOCWJFNTGl6g0/BF1SLPR+Xc4vGwVLqIdhAShkg=";
  };

  meta = with lib; {
    description = "Incremental LSP renaming based on Neovim's command-preview feature. ";
    homepage = "https://github.com/smjonas/inc-rename.nvim";
    license = licenses.mit;
    sourceProvenance = [sourceTypes.fromSource];
    maintainers = [];
  };
}
