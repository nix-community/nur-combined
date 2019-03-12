{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "youtube-rss-${version}";
  version = "2019-03-11";

  src = fetchFromGitHub {
    owner = "JohnAZoidberg";
    repo = "YoutubeRSS";
    rev = "a9c0fc3b83b4a731e055b7829b12aa0e45e00e27";
    sha256 = "0azapk00q0jv1xc2fz593dp6ya9l5aqykk0y97mic5zzw7mgcfav";
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

