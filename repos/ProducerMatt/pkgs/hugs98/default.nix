{ stdenv, lib, fetchFromGitHub, ... }:

let
  commonMeta = rec {
    name = "hugs98";
    version = "2020-11-21";
  };
in stdenv.mkDerivation {
  name = "${commonMeta.name}_${commonMeta.version}";

  src = fetchFromGitHub {
    owner = "FranklinChen";
    repo = "hugs98-plus-Sep2006";
    rev = "54ab69bd6313adbbed1d790b46aca2a0305ea67e";
    sha256 = "qWnr+eh2DP4dZMCr+5Pi2mRTRymPOaOBK8iTHE9LtOc=";
  };
  meta = {
    broken = true; # FIXME
    homepage = "https://github.com/FranklinChen/hugs98-plus-Sep2006";
    platforms = [ "x86_64-linux" ];
    license = with lib.licenses; [ bsd3 ];
    maintainers = [ lib.maintainers.ProducerMatt ];
  };
}
