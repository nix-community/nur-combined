{
  lib,
  hmcl,
  jdk,
  jdk17,
  jdk21,
  jdks ? [
    jdk
    jdk17
    jdk21
  ],
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:
hmcl.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "hmcl-multi-jdk";

    desktopItems = [
      (makeDesktopItem {
        name = "hmcl-multi-jdk";
        exec = "hmcl-multi-jdk";
        icon = "hmcl";
        comment = finalAttrs.meta.description;
        desktopName = "HMCL Multi-JDK";
        categories = [ "Game" ];
      })
    ];

    nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
      makeWrapper
      copyDesktopItems
    ];

    postFixup =
      previousAttrs.postFixup or ""
      + ''
        makeWrapper ${hmcl}/bin/hmcl $out/bin/hmcl-multi-jdk \
          --prefix PATH : "${lib.makeBinPath jdks}"
      '';

    meta = hmcl.meta // {
      mainProgram = "hmcl-multi-jdk";
      description = "HMCL with multiple JDK support";
    };
  }
)
