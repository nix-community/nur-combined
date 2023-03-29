{
  lib,
  fetchzip,
  stdenv,
  undmg,
}:
stdenv.mkDerivation rec {
  pname = "copyq";
  version = "6.4.0";

  src = fetchzip {
    url = "https://github.com/hluk/CopyQ/releases/download/v${version}/CopyQ.dmg.zip";
    hash = "sha256-sHggRlyog+t+SWyo6sTKtJcfuEu/hgyNVXrd7sOK2XQ=";
  };

  nativeBuildInputs = [undmg];
  unpackCmd = ''
    undmg $curSrc/CopyQ.dmg
  '';

  sourceRoot = "CopyQ.app";

  installPhase = ''
    mkdir -p $out/Applications/CopyQ.app
    cp -R . $out/Applications/CopyQ.app
  '';

  meta = with lib; {
    homepage = "https://hluk.github.io/CopyQ";
    description = "Clipboard Manager with Advanced Features";
    license = licenses.gpl3Only;
    platforms = platforms.darwin;
  };
}
