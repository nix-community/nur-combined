{ stdenv, lib, fetchFromGitHub, pkgs, ... }:

let
  commonMeta = rec {
    name = "orgmk";
    version = "2022-01-20";
  };
in stdenv.mkDerivation {
  name = "${commonMeta.name}_${commonMeta.version}";

  buildInputs = with pkgs; [
    emacs28NativeComp
  ];
  patches = [ ./params.patch ];
  preBuild = ''
  '';
  dontInstall = true;
  preFixup = ''
    mkdir -p $out/bin
    mkdir -p $out/share/orgmk
    cp -r bin/* $out/bin/
  '';
  src = fetchFromGitHub {
    owner = "fniessen";
    repo = "orgmk";
    rev = "ba72326";
    sha256 = "+2ldIlT7OFbYm+DWaP44eaiCacfQddjPRd1xasvE7/I=";
  };
  meta = {
    homepage = "https://github.com/fniessen/orgmk";
    platforms = [ "x86_64-linux" ];
    license = with lib.licenses; [ gpl3 ];
    maintainers = [ lib.maintainers.ProducerMatt ];
  };
}
