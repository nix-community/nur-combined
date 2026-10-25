{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation rec {
  pname = "anylinuxfs-gui";
  version = "0.7.2";

  src = fetchurl {
    url = "https://github.com/fenio/anylinuxfs-gui/releases/download/v0.7.2/anylinuxfs-gui_0.7.2_aarch64.dmg";
    hash = "sha256-e5INmXsSc2ptk8FOy2DG/saMNHCjpvQNvswSC+yQaos=";
  };

  # The release DMG uses APFS, which undmg cannot unpack.
  nativeBuildInputs = [ _7zz ];
  sourceRoot = ".";
  unpackCmd = "7zz x -snld $curSrc";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r "anylinuxfs-gui.app" $out/Applications/
    runHook postInstall
  '';

  meta = with lib; {
    description = "macOS GUI for anylinuxfs - mount Linux filesystems on macOS";
    homepage = "https://github.com/fenio/anylinuxfs-gui";
    license = licenses.gpl3Plus; # Most casks are proprietary
    maintainers = [ ];
    platforms = platforms.darwin;
  };
}
