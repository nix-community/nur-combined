{
  stdenv,
  lib,
  vscode,
  logo-url ? "https://raw.githubusercontent.com/Aikoyori/ProgrammingVTuberLogos/main/VSCode/VSCode.png",
}:
let
  path =
    if stdenv.isDarwin then
      "Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/"
    else
      "resources/app/out/vs/workbench/workbench.desktop.main.css";

in
vscode.overrideAttrs (oldAttrs: {
  postPatch =
    ''
      echo ".editor-group-watermark > .letterpress{
        background-image: url(${logo-url}) !important;
        opacity: .75;
      }" >> ${path}
    ''
    + oldAttrs.postPatch;

  meta = oldAttrs.meta // {
    description = "VSCode with github.com/Aikoyori/ProgrammingVTuberLogos LOGO";
    maintainers = with lib.maintainers; [ Cryolitia ];
  };
})
