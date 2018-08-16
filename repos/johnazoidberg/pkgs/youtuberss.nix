{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "youtube-rss-${version}";
  version = "2018-05-28";

  src = fetchFromGitHub {
    owner = "JohnAZoidberg";
    repo = "YoutubeRSS";
    rev = "0f610ceba8c7507e21ed525f56bdbbe866ed012c";
    sha256 = "0iq9da9f2pypgilhn94zll4z15ynix3yh349ixqnhkxdm3jkz4ml";
  };

  installPhase = ''
    mkdir $out
    cp -ra * $out/
  '';

  meta = with stdenv.lib; {
    description = "Generate an audio-only podcast rss feed from any YouTube channel or playlist";
    license = licenses.bsd3;
    homepage = https://github.com/JohnAZoidberg/YoutubeRSS;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

