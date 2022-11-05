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
  tag = "v2.3.2-6";
  version = "2.3.2";

in stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "${rp}https://github.com/Riceneeder/electronic-wechat/releases/download/${tag}/electronic-wechat_${version}_amd64.deb";
    sha256 = "24d2b3a8ff1609b2f3c0fa894fcea15831fa5a2bf5c89f1d022352c7d1089e4f";
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
    description = "A WeChat client based on Electron";
    homepage = "https://github.com/Riceneeder/electronic-wechat";
    license = licenses.mit;
  };
}