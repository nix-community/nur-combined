{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "csvquote";
  version = "2018-05-28";

  src = fetchFromGitHub {
    owner = "dbro";
    repo = "csvquote";
    rev = "baf37fa4cccc656282551db4ea7ce4ec6b9c318e";
    hash = "sha256-Pi50Gd1YSBmCHuaPs0WLQzt6pIubcJj5riBSW0V5fxo=";
  };

  makeFlags = [ "BINDIR=$(out)/bin" ];

  preInstall = "mkdir -p $out/bin";

  meta = with lib; {
    description = "Enables common unix utlities like cut, awk, wc, head to work correctly with csv data containing delimiters and newlines";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
