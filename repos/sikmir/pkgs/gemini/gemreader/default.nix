{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gemreader";
  version = "2021-03-08";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "gemreader";
    rev = "7f9df147d6785d5f2b77ce9d44513de65985657a";
    hash = "sha256-1IqxMBLmcfFIdv11FbGbXVRPc05LmSqPieeaj4uf0nA=";
  };

  vendorHash = "sha256-NzrZh2dePytF1vsXzfqoeLnzdlcDThjZIkfwuXTAfXM=";

  meta = with lib; {
    description = "Feed reader for the Geminispace";
    inherit (src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
