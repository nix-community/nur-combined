{
  vscode,
  logo-url ? "https://raw.githubusercontent.com/Aikoyori/ProgrammingVTuberLogos/main/VSCode/VSCode.png",
}:

vscode.overrideAttrs (oldAttrs: {
  postPatch =
    ''
      echo ".editor-group-watermark > .letterpress{
        background-image: url(${logo-url}) !important;
        opacity: .75;
      }" >> resources/app/out/vs/workbench/workbench.desktop.main.css
    ''
    + oldAttrs.postPatch;

  meta = oldAttrs.meta // {
    description = "VSCode with github.com/Aikoyori/ProgrammingVTuberLogos LOGO";
  };
})
