{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule {
  pname = "gemreader";
  version = "0-unstable-2021-03-08";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "gemreader";
    rev = "7f9df147d6785d5f2b77ce9d44513de65985657a";
    hash = "sha256-1IqxMBLmcfFIdv11FbGbXVRPc05LmSqPieeaj4uf0nA=";
  };

  vendorHash = "sha256-NzrZh2dePytF1vsXzfqoeLnzdlcDThjZIkfwuXTAfXM=";

  meta = {
    description = "Feed reader for the Geminispace";
    homepage = "https://git.sr.ht/~sircmpwn/gemreader";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
