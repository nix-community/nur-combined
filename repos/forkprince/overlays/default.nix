{
  default = final: prev: {
    zed-editor =
      if prev.stdenvNoCC.isDarwin
      then prev.zed-editor
      else prev.zed-editor-fhs;

    ghostty =
      if prev.stdenvNoCC.isDarwin
      then prev.ghostty-bin
      else prev.ghostty;

    micro =
      if prev.stdenvNoCC.isDarwin
      then prev.micro
      else prev.micro-full;

    vscode =
      if prev.stdenvNoCC.isDarwin
      then prev.vscode
      else prev.vscode-fhs;
  };
}
