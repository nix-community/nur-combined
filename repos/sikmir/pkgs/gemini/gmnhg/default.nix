{ lib, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "gmnhg";
  version = "0.1.1";

  src = fetchgit {
    url = "https://git.tdem.in/tdemin/gmnhg";
    rev = "v${version}";
    sha256 = "0vvcfiw31rx31j4qi0ql8bpm3xvzrg5hbzfzq2f0vy1s23wwazkd";
  };

  vendorSha256 = "1cc899bvjlk3j8hqm7gyxssc5yjjv46jl4fpwycyr75cwvdz9bdb";

  meta = with lib; {
    description = "Hugo-to-Gemini Markdown converter";
    homepage = "https://git.tdem.in/tdemin/gmnhg";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
