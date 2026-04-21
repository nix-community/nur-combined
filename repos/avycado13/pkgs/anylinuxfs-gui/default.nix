{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg ? null,
  unzip ? null,
}:

stdenvNoCC.mkDerivation rec {
  pname = "anylinuxfs-gui";
  version = "0.7.2";

  src = fetchurl {
    url = "https://github.com/fenio/anylinuxfs-gui/releases/download/v0.7.2/anylinuxfs-gui_0.7.2_aarch64.dmg";
    hash = "sha256-e5INmXsSc2ptk8FOy2DG/saMNHCjpvQNvswSC+yQaos=";
  };

  nativeBuildInputs = [
    undmg
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r "anylinuxfs-gui.app" $out/Applications/
    runHook postInstall
  '';

  meta = with lib; {
    description = "macOS GUI for anylinuxfs - mount Linux filesystems on macOS";
    homepage = "https://github.com/fenio/anylinuxfs-gui";
    license = licenses.unfree;  # Most casks are proprietary
    maintainers = [ ];
    platforms = platforms.darwin;
  };
}
