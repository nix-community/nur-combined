{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gemreader";
  version = "2021-03-08";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "7f9df147d6785d5f2b77ce9d44513de65985657a";
    hash = "sha256-1IqxMBLmcfFIdv11FbGbXVRPc05LmSqPieeaj4uf0nA=";
  };

  vendorSha256 = "0wvxq1sbkw274bcihkh3axvg7fbqm3xcs5zvsr2jngsycy3xjfip";

  meta = with lib; {
    description = "Feed reader for the Geminispace";
    inherit (src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
