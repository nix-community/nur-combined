{stdenv}:
stdenv.mkDerivation {
  pname = "wechat-license";
  version = "0.0.1";
  src = ./license.tar.gz;

  installPhase = ''
    mkdir -p $out
    cp -r etc var $out/
  '';
}
