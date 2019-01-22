{ stdenv, lib, pkgs, curl, jansson ,fetchFromGitHub, autoreconfHook }:
stdenv.mkDerivation rec {
  pname = "baidudl";
  version = "2018-01-16";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "yzfedora";
    repo = "baidudl";
    rev = "712f2554a5ef7b2eba5c248d6406a6c535ef47b2";
    sha256 = "1nfzalyd9k87q6njdxpg7pa62q6hyfr2vwxwvahaflyp31nlpa0y";
  };


  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ curl.dev jansson ];

  meta = {
    homepage = https://github.com/yzfedora/baidudl;
    description = "This is a multi-thread download tool for pan.baidu.com";
    license = lib.licenses.gpl3;
  };
}
