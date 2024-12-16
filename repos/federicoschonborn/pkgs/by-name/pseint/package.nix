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
  version = "20240122";

  src = fetchurl {
    url = "mirror://sourceforge/project/pseint/${finalAttrs.version}/pseint-src-${finalAttrs.version}.tgz";
    hash = "sha256-OvmkSvMT7hhQWuBxaslJIZ0ZWFQGm0zjO9Qcrb/mVLA=";
  };

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    libGLU
    libglvnd
    wxGTK32
    xorg.libX11
  ];

  makeFlags = [ "ARCH=lnx" ];

  desktopItems = [
    (makeDesktopItem {
      name = "pseint";
      exec = "pseint";
      icon = "pseint";
      desktopName = "pseint";
      categories = [ "Development" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/pseint
    cp -r bin/. $out/opt/pseint
    ln -s $out/opt/pseint/bin/* $out/bin

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;
  # Uses the wrong version for some godforsaken reason.
  dontVersionCheck = true;

  meta = {
    description = "A tool for learning programming basis with a simple Spanish pseudocode";
    homepage = "https://pseint.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
