{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "goldendict-dark-theme";
  version = "2018-11-08";

  src = fetchgit {
    url = "https://gist.github.com/ilius/5a2f35c79775267fbdb249493c041453";
    rev = "5c616fa8120fbf8aee9bc2d33e70f54e0990e759";
    sha256 = "1rpkfcjp3dhdnrnf68id956hvm8bn655cp8v4if5s753vx5ni012";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm644 article-style.css $out/share/goldendict/styles/dark-theme/article-style.css
    install -Dm644 qt-style.css $out/share/goldendict/styles/dark-theme/qt-style.css
  '';

  meta = with stdenv.lib; {
    description = "GoldenDict Dark Theme";
    homepage = "https://gist.github.com/ilius/5a2f35c79775267fbdb249493c041453";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
