{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  libGLU,
  libglvnd,
  wxGTK32,
  xorg,
  tree,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pseint";
  version = "20250314";

  src = fetchurl {
    url = "mirror://sourceforge/project/pseint/${finalAttrs.version}/pseint-src-${finalAttrs.version}.tgz";
    hash = "sha256-ETLkkxzmzouVxzzjyhQGgp8Em8CjcF3YjeUdsiiOtSc=";
  };

  nativeBuildInputs = [
    wxGTK32 # wx-config
  ] ++ lib.optional stdenv.hostPlatform.isLinux copyDesktopItems;

  buildInputs = [
    libGLU
    libglvnd
    wxGTK32
    xorg.libX11
  ];

  makeFlags =
    [
      "GCC=cc"
      "GPP=c++"
      "AR=ar"
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux "ARCH=lnx"
    ++ lib.optional stdenv.hostPlatform.isDarwin (
      {
        "x86_64-darwin" = "ARCH=mi64";
        "aarch64-darwin" = "ARCH=ma64";
      }
      .${stdenv.hostPlatform.system} or (throw "unsupported system")
    );

  desktopItems = lib.optional stdenv.hostPlatform.isLinux (makeDesktopItem {
    name = "pseint";
    exec = "pseint";
    icon = "pseint";
    desktopName = "pseint";
    categories = [ "Development" ];
  });

  installPhase = ''
    runHook preInstall

    ${lib.getExe tree}
    mkdir -p $out/bin $out/share/pseint
    cp -r bin/. $out/share/pseint
    ln -s $out/share/pseint/bin/* $out/bin

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  # Prints the wrong version for some reason.
  doInstallCheck = false;
  installCheckProgram = "${placeholder "out"}/bin/pseint";
  installCheckProgramArg = "--version";

  strictDeps = true;

  meta = {
    mainProgram = "pseint";
    description = "A tool for learning programming basis with a simple Spanish pseudocode";
    homepage = "https://pseint.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
