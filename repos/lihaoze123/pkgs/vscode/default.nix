{ lib, vscode-with-extensions, vscode-extensions }:

(vscode-with-extensions.override {
  vscodeExtensions = with vscode-extensions; [
    dracula-theme.theme-dracula
    vscodevim.vim
    myriad-dreamin.tinymist
    ms-ceintl.vscode-language-pack-zh-hans
    adpyke.codesnap
    james-yu.latex-workshop
  ];
}).overrideAttrs (old: {
  meta = old.meta // {
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
