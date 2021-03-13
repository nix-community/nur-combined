{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gemreader";
  version = "2021-03-08";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "7f9df147d6785d5f2b77ce9d44513de65985657a";
    sha256 = "0w6jky5qz6p7i67jm6ab9rrlym2xkfqiaxgxfr4g2wg628qb32nl";
  };

  vendorSha256 = "0wvxq1sbkw274bcihkh3axvg7fbqm3xcs5zvsr2jngsycy3xjfip";

  meta = with lib; {
    description = "Feed reader for the Geminispace";
    homepage = "https://git.sr.ht/~sircmpwn/gemreader";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
