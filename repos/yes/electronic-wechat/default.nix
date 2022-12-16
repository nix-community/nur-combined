{ lib
, stdenvNoCC
, fetchurl
, binutils
, electron
, makeWrapper
, rp ? ""
}:

let
  pname = "electronic-wechat";
  tag = "v2.3.3-1";
  version = "2.3.3";
  homepage = "https://github.com/zzy-ac/electronic-wechat";

in stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "${rp}${homepage}/releases/download/${tag}/electronic-wechat_${version}_amd64.deb";
    hash = "sha256-D/FWEioctkBx0OK5Rm+KsoAUBKwpp2DTydMSS2yzZ3c=";
  };

  nativeBuildInputs = [ binutils makeWrapper ];

  unpackCmd = ''
    ar x $curSrc
    tar -xvf data.tar.xz
  '';

  installPhase = ''
    mkdir -p $out/{bin,share/${pname}}
    cp lib/${pname}/resources/app.asar $out/share/${pname}
    cp -r share/{applications,pixmaps} $out/share
    makeWrapper ${electron}/bin/electron $out/bin/electronic-wechat \
      --add-flags $out/share/${pname}/app.asar
  '';

  meta = with lib; {
    inherit homepage;
    description = "A WeChat client based on Electron";
    license = licenses.mit;
  };
}