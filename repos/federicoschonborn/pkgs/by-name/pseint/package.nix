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

  strictDeps = true;

  makeFlags =
    [
      "GCC=cc"
      "GPP=c++"
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

  installPhase =
    if stdenv.hostPlatform.isLinux then
      ''
        runHook preInstall

        mkdir -p $out/bin $out/share/pseint
        cp -r bin/. $out/share/pseint
        for name in psdraw3 psdrawE pseint pseval psexport psterm; do
          ln -sr $out/share/pseint/bin/$name $out/bin/$name
        done

        runHook postInstall
      ''
    else if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall

        appDir=$out/Applications/pseint.app/Contents
        mkdir -p $appDir/MacOS $appDir/Resources
        cp -r bin/. $appDir/Resources
        ln -sr $appDir/Resources/pseint $appDir/MacOS/pseint
        cp dist/Info.plist $appDir/Info.plist

        runHook postInstall
      ''
    else
      throw "unsupported platform";

  nativeInstallCheckInputs = [ versionCheckHook ];
  # Prints the wrong version for some reason.
  doInstallCheck = false;

  meta = {
    mainProgram = "pseint";
    description = "A tool for learning programming basis with a simple Spanish pseudocode";
    homepage = "https://pseint.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
